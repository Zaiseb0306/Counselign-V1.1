<?php
// File: app/Models/QuoteModel.php

namespace App\Models;

use CodeIgniter\Model;
use App\Helpers\TimezoneHelper;

class QuoteModel extends Model
{
    protected $table = 'daily_quotes';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'quote_text',
        'author_name',
        'category',
        'source',
        'submitted_by_id',
        'submitted_by_name',
        'submitted_by_role',
        'status',
        'moderated_by',
        'moderated_at',
        'rejection_reason',
        'times_displayed',
        'last_displayed_date'
    ];
    
    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';
    
    protected $validationRules = [
        'quote_text' => 'required|min_length[10]|max_length[500]',
        'author_name' => 'required|min_length[2]|max_length[255]',
        'category' => 'required|in_list[Inspirational,Motivational,Wisdom,Life,Success,Education,Perseverance,Courage,Hope,Kindness]'
    ];
    
    protected $validationMessages = [
        'quote_text' => [
            'required' => 'Quote text is required',
            'min_length' => 'Quote must be at least 10 characters',
            'max_length' => 'Quote cannot exceed 500 characters'
        ],
        'author_name' => [
            'required' => 'Author name is required',
            'min_length' => 'Author name must be at least 2 characters'
        ],
        'category' => [
            'required' => 'Category is required',
            'in_list' => 'Invalid category selected'
        ]
    ];

    /**
     * Constructor - Set Manila timezone for database operations
     */
    public function __construct()
    {
        parent::__construct();
        
        // Ensure Manila timezone for all database operations
        $this->db->query("SET time_zone = '+08:00'");
    }
    
    /**
     * Get a random approved quote that hasn't been shown recently
     * Uses Manila timezone for date comparison
     */
    public function getRandomApprovedQuote()
    {
        $today = TimezoneHelper::getManilaDate();
        
        // Try to get a quote that hasn't been shown today (Manila time)
        $quote = $this->where('status', 'approved')
                     ->groupStart()
                         ->where('last_displayed_date !=', $today)
                         ->orWhere('last_displayed_date', null)
                     ->groupEnd()
                     ->orderBy('RAND()')
                     ->first();
        
        // If all quotes have been shown today, get any approved quote
        if (!$quote) {
            $quote = $this->where('status', 'approved')
                         ->orderBy('RAND()')
                         ->first();
        }
        
        // Update display tracking with Manila date
        if ($quote) {
            $this->update($quote['id'], [
                'times_displayed' => $quote['times_displayed'] + 1,
                'last_displayed_date' => $today
            ]);
        }
        
        return $quote;
    }
    
    /**
     * Get all quotes for counselor (their own submissions)
     */
    public function getCounselorQuotes($counselorId)
    {
        return $this->where('submitted_by_id', $counselorId)
                    ->orderBy('created_at', 'DESC')
                    ->findAll();
    }
    
    /**
     * Get all quotes for admin moderation
     */
    public function getAllQuotesForModeration()
    {
        try {
            $db = \Config\Database::connect();
            
            // Use raw query for better control and to handle the status ordering
            $query = $db->query("
                SELECT 
                    daily_quotes.*, 
                    users.username as moderator_username
                FROM daily_quotes
                LEFT JOIN users ON users.id = daily_quotes.moderated_by
                ORDER BY 
                    CASE daily_quotes.status
                        WHEN 'pending' THEN 1
                        WHEN 'approved' THEN 2
                        WHEN 'rejected' THEN 3
                        ELSE 4
                    END ASC,
                    daily_quotes.created_at DESC
            ");
            
            return $query->getResultArray();
        } catch (\Exception $e) {
            log_message('error', '[QuoteModel] Error in getAllQuotesForModeration: ' . $e->getMessage());
            log_message('error', '[QuoteModel] Stack trace: ' . $e->getTraceAsString());
            // Fallback to simple query without join if there's an error
            return $this->orderBy('created_at', 'DESC')->findAll();
        }
    }
    
    /**
     * Get pending quotes count
     */
    public function getPendingCount()
    {
        return $this->where('status', 'pending')->countAllResults();
    }
    
    /**
     * Approve a quote with Manila timestamp
     */
    public function approveQuote($quoteId, $moderatorId)
    {
        return $this->update($quoteId, [
            'status' => 'approved',
            'moderated_by' => $moderatorId,
            'moderated_at' => TimezoneHelper::getManilaDateTime(),
            'rejection_reason' => null
        ]);
    }
    
    /**
     * Reject a quote with Manila timestamp
     */
    public function rejectQuote($quoteId, $moderatorId, $reason = null)
    {
        return $this->update($quoteId, [
            'status' => 'rejected',
            'moderated_by' => $moderatorId,
            'moderated_at' => TimezoneHelper::getManilaDateTime(),
            'rejection_reason' => $reason
        ]);
    }

    /**
     * Override insert to ensure Manila timezone
     * Note: created_at is automatically set by CI4 timestamps
     */
    public function insert($data = null, bool $returnID = true)
    {
        return parent::insert($data, $returnID);
    }
}