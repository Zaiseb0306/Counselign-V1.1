<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;
use CodeIgniter\API\ResponseTrait;
use App\Models\ResourceModel;

class Resources extends BaseController
{
    use ResponseTrait;

    public function index()
    {
        // Check if user is logged in and is admin
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return redirect()->to('/');
        }

        return view('admin/resources');
    }

    /**
     * Get all resources
     */
    public function getResources()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceModel = new ResourceModel();
            
            // Get filters from query params
            $filters = [
                'category' => $this->request->getGet('category'),
                'resource_type' => $this->request->getGet('resource_type'),
                'visibility' => $this->request->getGet('visibility'),
                'search' => $this->request->getGet('search')
            ];
            
            if ($this->request->getGet('is_active') !== null) {
                $filters['is_active'] = $this->request->getGet('is_active');
            }
            
            $resources = $resourceModel->getAllResourcesWithUploader($filters);
            
            // Format file sizes and dates
            foreach ($resources as &$resource) {
                if ($resource['file_size']) {
                    $resource['file_size_formatted'] = $this->formatFileSize($resource['file_size']);
                }
                $resource['created_at_formatted'] = date('M d, Y h:i A', strtotime($resource['created_at']));
            }
            
            return $this->respond(['success' => true, 'resources' => $resources]);
        } catch (\Exception $e) {
            log_message('error', '[Resources] Error fetching resources: ' . $e->getMessage());
            return $this->respond(['success' => false, 'message' => 'Failed to load resources'], 500);
        }
    }

    /**
     * Create new resource
     */
    public function create()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceType = $this->request->getPost('resource_type');
            
            $data = [
                'title' => $this->request->getPost('title'),
                'description' => $this->request->getPost('description'),
                'resource_type' => $resourceType,
                'category' => $this->request->getPost('category'),
                'tags' => $this->request->getPost('tags'),
                'visibility' => $this->request->getPost('visibility') ?? 'all',
                'uploaded_by' => session()->get('user_id_display') ?? (string) session()->get('user_id'),
                'is_active' => $this->request->getPost('is_active') ?? 1
            ];

            if ($resourceType === 'link') {
                $data['external_url'] = $this->request->getPost('external_url');
                
                if (empty($data['external_url'])) {
                    return $this->respond(['success' => false, 'message' => 'URL is required for link resources'], 400);
                }
            } else {
                // Handle file upload
                $file = $this->request->getFile('file');
                
                if (!$file || !$file->isValid()) {
                    return $this->respond(['success' => false, 'message' => 'Please select a valid file'], 400);
                }
                
                // Validate file size (50MB max)
                if ($file->getSize() > 50 * 1024 * 1024) {
                    return $this->respond(['success' => false, 'message' => 'File size exceeds 50MB limit'], 400);
                }
                
                // Create upload directory if it doesn't exist
                $uploadPath = FCPATH . 'uploads/resources/';
                if (!is_dir($uploadPath)) {
                    mkdir($uploadPath, 0755, true);
                }
                
                // Generate unique filename
                $originalName = $file->getClientName();
                $extension = $file->getClientExtension();
                $newName = time() . '_' . bin2hex(random_bytes(8)) . '.' . $extension;
                
                // Move file
                if (!$file->move($uploadPath, $newName)) {
                    return $this->respond(['success' => false, 'message' => 'Failed to upload file'], 500);
                }
                
                $data['file_name'] = $originalName;
                $data['file_path'] = 'uploads/resources/' . $newName;
                $data['file_type'] = $file->getClientMimeType();
                $data['file_size'] = $file->getSize();
            }

            $resourceModel = new ResourceModel();
            
            if ($resourceModel->insert($data)) {
                log_message('info', '[Resources] Resource created by admin: ' . session()->get('user_id'));
                return $this->respond(['success' => true, 'message' => 'Resource added successfully']);
            } else {
                return $this->respond(['success' => false, 'message' => 'Failed to save resource'], 500);
            }
        } catch (\Exception $e) {
            log_message('error', '[Resources] Error creating resource: ' . $e->getMessage());
            return $this->respond(['success' => false, 'message' => 'An error occurred: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Update resource
     */
    public function update($id)
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceModel = new ResourceModel();
            $existing = $resourceModel->find($id);
            
            if (!$existing) {
                return $this->respond(['success' => false, 'message' => 'Resource not found'], 404);
            }

            $data = [
                'title' => $this->request->getPost('title'),
                'description' => $this->request->getPost('description'),
                'category' => $this->request->getPost('category'),
                'tags' => $this->request->getPost('tags'),
                'visibility' => $this->request->getPost('visibility') ?? 'all',
                'is_active' => $this->request->getPost('is_active') ?? 1,
                'resource_type' => $existing['resource_type'],
                'uploaded_by' => $existing['uploaded_by'],
            ];

            // Handle URL update for link type
            if ($existing['resource_type'] === 'link') {
                $data['external_url'] = $this->request->getPost('external_url');
            }

            // Handle file replacement if new file uploaded
            $file = $this->request->getFile('file');
            if ($file && $file->isValid() && $existing['resource_type'] === 'file') {
                // Delete old file
                if (!empty($existing['file_path'])) {
                    $oldFilePath = FCPATH . $existing['file_path'];
                    if (file_exists($oldFilePath)) {
                        @unlink($oldFilePath);
                    }
                }
                
                // Upload new file
                $uploadPath = FCPATH . 'uploads/resources/';
                $originalName = $file->getClientName();
                $extension = $file->getClientExtension();
                $newName = time() . '_' . bin2hex(random_bytes(8)) . '.' . $extension;
                
                if ($file->move($uploadPath, $newName)) {
                    $data['file_name'] = $originalName;
                    $data['file_path'] = 'uploads/resources/' . $newName;
                    $data['file_type'] = $file->getClientMimeType();
                    $data['file_size'] = $file->getSize();
                }
            }

            if ($resourceModel->update($id, $data)) {
                log_message('info', '[Resources] Resource updated: ' . $id);
                return $this->respond(['success' => true, 'message' => 'Resource updated successfully']);
            } else {
                return $this->respond(['success' => false, 'message' => 'Failed to update resource'], 500);
            }
        } catch (\Exception $e) {
            log_message('error', '[Resources] Error updating resource: ' . $e->getMessage());
            return $this->respond(['success' => false, 'message' => 'An error occurred'], 500);
        }
    }

    /**
     * Delete resource
     */
    public function delete($id)
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceModel = new ResourceModel();
            
            if ($resourceModel->deleteResource($id)) {
                log_message('info', '[Resources] Resource deleted: ' . $id);
                return $this->respond(['success' => true, 'message' => 'Resource deleted successfully']);
            } else {
                return $this->respond(['success' => false, 'message' => 'Resource not found'], 404);
            }
        } catch (\Exception $e) {
            log_message('error', '[Resources] Error deleting resource: ' . $e->getMessage());
            return $this->respond(['success' => false, 'message' => 'Failed to delete resource'], 500);
        }
    }

    /**
     * Download file
     */
    public function download($id)
    {
        if (!session()->get('logged_in')) {
            return redirect()->to('/');
        }

        try {
            $resourceModel = new ResourceModel();
            $resource = $resourceModel->find($id);
            
            if (!$resource || $resource['resource_type'] !== 'file') {
                return redirect()->back()->with('error', 'File not found');
            }
            
            $filePath = FCPATH . $resource['file_path'];
            
            if (!file_exists($filePath)) {
                return redirect()->back()->with('error', 'File not found on server');
            }
            
            // Increment download count
            $resourceModel->incrementDownloadCount($id);
            
            return $this->response->download($filePath, null)->setFileName($resource['file_name']);
        } catch (\Exception $e) {
            log_message('error', '[Resources] Error downloading file: ' . $e->getMessage());
            return redirect()->back()->with('error', 'Failed to download file');
        }
    }

    /**
     * Get categories
     */
    public function getCategories()
    {
        if (!session()->get('logged_in')) {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceModel = new ResourceModel();
            $categories = $resourceModel->getCategories();
            
            return $this->respond(['success' => true, 'categories' => $categories]);
        } catch (\Exception $e) {
            return $this->respond(['success' => false, 'message' => 'Failed to load categories'], 500);
        }
    }

    /**
     * Format file size
     */
    private function formatFileSize($bytes)
    {
        if ($bytes >= 1073741824) {
            return number_format($bytes / 1073741824, 2) . ' GB';
        } elseif ($bytes >= 1048576) {
            return number_format($bytes / 1048576, 2) . ' MB';
        } elseif ($bytes >= 1024) {
            return number_format($bytes / 1024, 2) . ' KB';
        } else {
            return $bytes . ' bytes';
        }
    }
}