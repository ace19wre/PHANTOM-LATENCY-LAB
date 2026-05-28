#!/bin/bash
# Local Live Autograder Engine (Task Validation Mode) - FIXED FOR DOCKER ENV

ALL_COMPLETED=true

echo "=================================================="
echo "      PROD-APP-01 IN-SITU EVALUATION SYSTEM       "
echo "=================================================="

# Evaluation UI output helper
evaluate() {
    if [ "$2" = "PASS" ]; then
        echo -e "[\e[32mCOMPLETE\e[0m] $1"
    else
        echo -e "[\e[31mINCOMPLETE\e[0m] $1"
        ALL_COMPLETED=false
    fi
}

# --- PART 1: SCRIPTING LOG CHECK ---
LOG_PATH="/home/student/network_incident_log.txt"
if [ -f "$LOG_PATH" ]; then
    # FIXED: Now checks for the actual Docker router IPs causing the loop/delay
    CHECK_HOP=$(grep -c -E "(192.168.241.10|192.168.242.5|192.168.242.10)" "$LOG_PATH" 2>/dev/null)
    CHECK_ROUTE=$(grep -c -E "(Kernel|Gateway|Destination)" "$LOG_PATH" 2>/dev/null)
    
    if [ "$CHECK_HOP" -gt 0 ] && [ "$CHECK_ROUTE" -gt 0 ]; then
        evaluate "Part 1: Network Incident Log parsed metrics successfully" "PASS"
    else
        evaluate "Part 1: Log file found, but metrics or route dumps are missing" "FAIL"
    fi
else
    evaluate "Part 1: Target log 'network_incident_log.txt' not found in home folder" "FAIL"
fi

# --- PART 2: MITIGATION CHECK ---
# FIXED: Updated target subnet and backup gateway IPs to match Docker environment
ROUTE_CHECK=$(ip route show 192.168.243.0/24 2>/dev/null | grep "via 192.168.241.254")
if [ -n "$ROUTE_CHECK" ]; then
    evaluate "Part 2: Routing loop resolved via backup gateway" "PASS"
else
    evaluate "Part 2: Traffic to 192.168.243.0/24 is still trapped in a loop" "FAIL"
fi

# --- PART 3: THREAT HUNTING PID CHECK ---
PID_FILE="/home/student/suspicious_pid.txt"
if [ -f "$PID_FILE" ]; then
    STUDENT_PID=$(cat "$PID_FILE" | tr -d '\r\n ')
    
    # ADMIN FIX: Added 'sudo' so the grading engine can read the root-owned python socket
    ACTUAL_PID=$(sudo netstat -tnpa 2>/dev/null | grep '198.51.100.42' | awk '{print $7}' | cut -d'/' -f1 | head -n 1)
    
    if [ -n "$ACTUAL_PID" ] && [ "$STUDENT_PID" = "$ACTUAL_PID" ]; then
        evaluate "Part 3: Malicious process ID isolated correctly" "PASS"
    else
        evaluate "Part 3: Mismatch. Isolated PID does not match the active threat socket" "FAIL"
    fi
else
    evaluate "Part 3: Target file 'suspicious_pid.txt' not found" "FAIL"
fi

# --- LAB COMPLETION SUMMARY ---
echo "--------------------------------------------------"
if [ "$ALL_COMPLETED" = true ]; then
    echo -e "\e[32m\e[1mLAB STATUS: ALL TASKS COMPLETED SUCCESSFULLY!\e[0m"
    echo "COMPLETED" > /home/student/.current_grade 2>/dev/null
else
    echo -e "\e[31m\e[1mLAB STATUS: PENDING ACTIONS REMAIN\e[0m"
    echo "INCOMPLETE" > /home/student/.current_grade 2>/dev/null
fi
echo "=================================================="