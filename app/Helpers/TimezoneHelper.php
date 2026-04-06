<?php
// File: app/Helpers/TimezoneHelper.php

namespace App\Helpers;

class TimezoneHelper
{
    /**
     * Get current Manila datetime
     * 
     * @return string Current datetime in Manila timezone (Y-m-d H:i:s format)
     */
    public static function getManilaDateTime(): string
    {
        $dt = new \DateTime('now', new \DateTimeZone('Asia/Manila'));
        return $dt->format('Y-m-d H:i:s');
    }

    /**
     * Get current Manila date
     * 
     * @return string Current date in Manila timezone (Y-m-d format)
     */
    public static function getManilaDate(): string
    {
        $dt = new \DateTime('now', new \DateTimeZone('Asia/Manila'));
        return $dt->format('Y-m-d');
    }

    /**
     * Convert any datetime to Manila timezone
     * 
     * @param string $datetime DateTime string to convert
     * @param string $fromTimezone Source timezone (default: UTC)
     * @return string Converted datetime in Manila timezone
     */
    public static function convertToManila(string $datetime, string $fromTimezone = 'UTC'): string
    {
        try {
            $dt = new \DateTime($datetime, new \DateTimeZone($fromTimezone));
            $dt->setTimezone(new \DateTimeZone('Asia/Manila'));
            return $dt->format('Y-m-d H:i:s');
        } catch (\Exception $e) {
            log_message('error', 'Timezone conversion error: ' . $e->getMessage());
            return $datetime;
        }
    }

    /**
     * Format datetime for display in Manila timezone
     * 
     * @param string $datetime DateTime string
     * @param string $format Output format (default: 'M j, Y g:i A')
     * @return string Formatted datetime
     */
    public static function formatManilaDateTime(string $datetime, string $format = 'M j, Y g:i A'): string
    {
        try {
            $dt = new \DateTime($datetime, new \DateTimeZone('Asia/Manila'));
            return $dt->format($format);
        } catch (\Exception $e) {
            log_message('error', 'DateTime format error: ' . $e->getMessage());
            return $datetime;
        }
    }

    /**
     * Get Manila timezone offset
     * 
     * @return string Timezone offset (+08:00)
     */
    public static function getManilaOffset(): string
    {
        return '+08:00';
    }

    /**
     * Check if a date is today in Manila timezone
     * 
     * @param string $date Date string to check
     * @return bool True if date is today
     */
    public static function isToday(string $date): bool
    {
        $today = self::getManilaDate();
        $checkDate = date('Y-m-d', strtotime($date));
        return $today === $checkDate;
    }
}