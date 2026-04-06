<?php

namespace App\Models;

use CodeIgniter\Model;

class ResourceModel extends Model
{
    protected $table = 'resources';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = [
        'title',
        'description',
        'resource_type',
        'file_name',
        'file_path',
        'file_type',
        'file_size',
        'external_url',
        'category',
        'tags',
        'uploaded_by',
        'visibility',
        'is_active',
        'view_count',
        'download_count'
    ];

    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    protected $validationRules = [
        'title' => 'required|max_length[255]',
        'resource_type' => 'required|in_list[file,link]',
        'uploaded_by' => 'required|alpha_numeric|max_length[100]',
        'visibility' => 'permit_empty|in_list[all,students,counselors]'
    ];

    protected $validationMessages = [
        'title' => [
            'required' => 'Resource title is required',
            'max_length' => 'Title cannot exceed 255 characters'
        ],
        'resource_type' => [
            'required' => 'Resource type is required',
            'in_list' => 'Invalid resource type'
        ]
    ];

    protected $skipValidation = false;
    protected $cleanValidationRules = true;

    /**
     * Get all resources with uploader information
     */
    public function getAllResourcesWithUploader($filters = [])
    {
        $builder = $this->db->table($this->table);
        $builder->select('resources.*, users.username as uploader_name, users.email as uploader_email');
        $builder->join('users', 'users.user_id = resources.uploaded_by', 'left');
        
        // Apply filters
        if (!empty($filters['category'])) {
            $builder->where('resources.category', $filters['category']);
        }
        
        if (!empty($filters['resource_type'])) {
            $builder->where('resources.resource_type', $filters['resource_type']);
        }
        
        if (!empty($filters['visibility'])) {
            $builder->where('resources.visibility', $filters['visibility']);
        }
        
        if (isset($filters['is_active'])) {
            $builder->where('resources.is_active', $filters['is_active']);
        }
        
        if (!empty($filters['search'])) {
            $builder->groupStart();
            $builder->like('resources.title', $filters['search']);
            $builder->orLike('resources.description', $filters['search']);
            $builder->orLike('resources.tags', $filters['search']);
            $builder->groupEnd();
        }
        
        $builder->orderBy('resources.created_at', 'DESC');
        
        return $builder->get()->getResultArray();
    }

    /**
     * Get resources visible to a specific role
     */
    public function getResourcesByVisibility($visibility = 'all', $isActive = true)
    {
        $builder = $this->db->table($this->table);
        $builder->select('resources.*, users.username as uploader_name');
        $builder->join('users', 'users.user_id = resources.uploaded_by', 'left');
        
        if ($visibility !== 'admin') {
            $builder->groupStart();
            $builder->where('resources.visibility', $visibility);
            $builder->orWhere('resources.visibility', 'all');
            $builder->groupEnd();
        }
        
        if ($isActive) {
            $builder->where('resources.is_active', 1);
        }
        
        $builder->orderBy('resources.created_at', 'DESC');
        
        return $builder->get()->getResultArray();
    }

    /**
     * Increment view count
     */
    public function incrementViewCount($id)
    {
        return $this->db->table($this->table)
            ->where('id', $id)
            ->set('view_count', 'view_count + 1', false)
            ->update();
    }

    /**
     * Increment download count
     */
    public function incrementDownloadCount($id)
    {
        return $this->db->table($this->table)
            ->where('id', $id)
            ->set('download_count', 'download_count + 1', false)
            ->update();
    }

    /**
     * Get resource by ID with uploader info
     */
    public function getResourceWithUploader($id)
    {
        $builder = $this->db->table($this->table);
        $builder->select('resources.*, users.username as uploader_name, users.email as uploader_email');
        $builder->join('users', 'users.user_id = resources.uploaded_by', 'left');
        $builder->where('resources.id', $id);
        
        return $builder->get()->getRowArray();
    }

    /**
     * Get categories list
     */
    public function getCategories()
    {
        return $this->db->table($this->table)
            ->select('category')
            ->distinct()
            ->where('category IS NOT NULL')
            ->where('category !=', '')
            ->orderBy('category', 'ASC')
            ->get()
            ->getResultArray();
    }

    /**
     * Delete resource and associated file
     */
    public function deleteResource($id)
    {
        $resource = $this->find($id);
        
        if (!$resource) {
            return false;
        }
        
        // Delete physical file if it exists
        if ($resource['resource_type'] === 'file' && !empty($resource['file_path'])) {
            $filePath = FCPATH . $resource['file_path'];
            if (file_exists($filePath)) {
                @unlink($filePath);
            }
        }
        
        return $this->delete($id);
    }
}