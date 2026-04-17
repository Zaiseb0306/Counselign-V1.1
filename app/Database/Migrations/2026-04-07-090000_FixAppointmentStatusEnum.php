<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

/**
 * Fix Appointment Status Enum to match business logic
 *
 * Updates the appointments table status enum to include both 'rejected' and 'rescheduled'
 * as these represent different business states: rejected (denied request) vs rescheduled (moved time)
 */
class FixAppointmentStatusEnum extends Migration
{
    public function up()
    {
        // Update the enum to include both rejected and rescheduled
        $this->db->query("
            ALTER TABLE `appointments`
            MODIFY COLUMN `status` enum('pending','approved','rejected','rescheduled','completed','cancelled') NOT NULL DEFAULT 'pending'
        ");

        // Update the check constraint if it exists
        $tableInfo = $this->db->query("SHOW CREATE TABLE `appointments`")->getRow();
        $hasStatusCheck = strpos($tableInfo->{'Create Table'}, 'chk_appointment_status') !== false;

        if ($hasStatusCheck) {
            // Drop the old constraint
            $this->db->query("ALTER TABLE `appointments` DROP CONSTRAINT `chk_appointment_status`");

            // Add the updated constraint
            $this->db->query("
                ALTER TABLE `appointments`
                ADD CONSTRAINT `chk_appointment_status`
                CHECK (`status` IN ('pending', 'approved', 'rejected', 'rescheduled', 'completed', 'cancelled'))
            ");
        }
    }

    public function down()
    {
        // Revert to the old enum (only rescheduled, no rejected)
        $this->db->query("
            ALTER TABLE `appointments`
            MODIFY COLUMN `status` enum('pending','approved','rescheduled','completed','cancelled') NOT NULL DEFAULT 'pending'
        ");

        // Update the check constraint
        $tableInfo = $this->db->query("SHOW CREATE TABLE `appointments`")->getRow();
        $hasStatusCheck = strpos($tableInfo->{'Create Table'}, 'chk_appointment_status') !== false;

        if ($hasStatusCheck) {
            $this->db->query("ALTER TABLE `appointments` DROP CONSTRAINT `chk_appointment_status`");
            $this->db->query("
                ALTER TABLE `appointments`
                ADD CONSTRAINT `chk_appointment_status`
                CHECK (`status` IN ('pending', 'approved', 'rescheduled', 'completed', 'cancelled'))
            ");
        }
    }
}