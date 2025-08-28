@echo off
echo Fixing SSH Passwordless Access...

REM Check if SSH key exists
if exist "%USERPROFILE%\.ssh\id_rsa_ontrail" (
    echo SSH key exists
) else (
    echo Creating SSH key...
    ssh-keygen -t rsa -b 4096 -f "%USERPROFILE%\.ssh\id_rsa_ontrail" -N ""
)

REM Read public key
if exist "%USERPROFILE%\.ssh\id_rsa_ontrail.pub" (
    echo Public key found
    set /p PUBLIC_KEY=<"%USERPROFILE%\.ssh\id_rsa_ontrail.pub"
) else (
    echo Public key not found
    exit /b 1
)

REM Execute remote commands
echo Setting up SSH key on server...
ssh -o StrictHostKeyChecking=no root@85.208.51.194 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '%PUBLIC_KEY%' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp && mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys && echo 'SSH key setup complete'"

if %ERRORLEVEL% EQU 0 (
    echo SSH key setup successful
) else (
    echo SSH setup failed
    exit /b 1
)

REM Test connection
echo Testing SSH connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@85.208.51.194 "echo 'SSH test successful'"

if %ERRORLEVEL% EQU 0 (
    echo Passwordless SSH working!
) else (
    echo SSH test failed
    exit /b 1
)

echo SSH Passwordless Access Fixed!
