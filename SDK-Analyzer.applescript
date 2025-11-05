-- SDK Analyzer - Desktop Application
-- A user-friendly GUI for analyzing mobile apps for SDK detection

on run
	-- Display welcome dialog
	set welcomeMessage to "SDK Analyzer" & return & return & ¬
		"This tool analyzes mobile apps to detect SDKs and frameworks." & return & return & ¬
		"Select the platform you want to analyze:"

	set platformChoice to button returned of (display dialog welcomeMessage buttons {"Cancel", "Android (APK)", "iOS (App Store)"} default button "iOS (App Store)" with icon note with title "SDK Analyzer")

	if platformChoice is "iOS (App Store)" then
		analyzeIOS()
	else if platformChoice is "Android (APK)" then
		analyzeAndroid()
	end if
end run

-- iOS Analysis Function
on analyzeIOS()
	-- Get the directory where this app is located
	set appPath to path to me
	set appPosixPath to POSIX path of appPath
	if appPosixPath ends with "/" then
		set appPosixPath to text 1 thru -2 of appPosixPath
	end if
	set scriptDir to do shell script "dirname " & quoted form of appPosixPath

	-- First, check if ipatool is installed
	set ipatoolInstalled to false
	try
		do shell script "cd " & quoted form of scriptDir & " && export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\" && which ipatool"
		set ipatoolInstalled to true
	end try

	if not ipatoolInstalled then
		set setupMessage to "⚠️  Setup Required" & return & return & ¬
			"ipatool needs to be installed to download iOS apps." & return & return & ¬
			"Would you like to:" & return & return & ¬
			"1. Install automatically (requires Terminal)" & return & ¬
			"2. See installation instructions"

		display dialog setupMessage buttons {"Cancel", "Show Instructions", "Install Now"} default button "Show Instructions" with icon note with title "Setup Required"

		set setupChoice to button returned of result

		if setupChoice is "Show Instructions" then
			set instructions to "📋 Installation Instructions" & return & return & ¬
				"To install ipatool, open Terminal and run:" & return & return & ¬
				"1. Install Homebrew (if not installed):" & return & ¬
				"   /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" & return & return & ¬
				"2. Install ipatool:" & return & ¬
				"   brew install ipatool" & return & return & ¬
				"3. Return to SDK Analyzer and try again" & return & return & ¬
				"These commands will be copied to your clipboard."

			display dialog instructions buttons {"Copy Commands", "OK"} default button "Copy Commands" with icon note with title "Installation Instructions"

			if button returned of result is "Copy Commands" then
				set the clipboard to "# Install Homebrew (if needed)" & linefeed & "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" & linefeed & linefeed & "# Install ipatool" & linefeed & "brew install ipatool"
				display notification "Commands copied to clipboard! Paste in Terminal." with title "SDK Analyzer"
			end if

			return
		else if setupChoice is "Install Now" then
			set installMessage to "🔧 Installing ipatool..." & return & return & ¬
				"This will:" & return & ¬
				"1. Check for Homebrew" & return & ¬
				"2. Install ipatool" & return & return & ¬
				"Terminal will open. Please follow the prompts." & return & ¬
				"Return to SDK Analyzer when installation is complete."

			display dialog installMessage buttons {"Cancel", "Open Terminal"} default button "Open Terminal" with icon note with title "Installation"

			if button returned of result is "Open Terminal" then
				-- Create installation script
				set installScript to "#!/bin/bash" & linefeed & ¬
					"echo '╔════════════════════════════════════════════════╗'" & linefeed & ¬
					"echo '║  SDK Analyzer - ipatool Installation          ║'" & linefeed & ¬
					"echo '╚════════════════════════════════════════════════╝'" & linefeed & ¬
					"echo ''" & linefeed & ¬
					"echo 'Checking for Homebrew...'" & linefeed & ¬
					"if ! command -v brew &> /dev/null; then" & linefeed & ¬
					"    echo ''" & linefeed & ¬
					"    echo 'Homebrew not found. Installing Homebrew...'" & linefeed & ¬
					"    /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" & linefeed & ¬
					"    echo ''" & linefeed & ¬
					"    echo 'Adding Homebrew to PATH...'" & linefeed & ¬
					"    if [[ $(uname -m) == 'arm64' ]]; then" & linefeed & ¬
					"        eval \"$(/opt/homebrew/bin/brew shellenv)\"" & linefeed & ¬
					"    else" & linefeed & ¬
					"        eval \"$(/usr/local/bin/brew shellenv)\"" & linefeed & ¬
					"    fi" & linefeed & ¬
					"else" & linefeed & ¬
					"    echo '✓ Homebrew is installed'" & linefeed & ¬
					"fi" & linefeed & ¬
					"echo ''" & linefeed & ¬
					"echo 'Installing ipatool...'" & linefeed & ¬
					"brew install ipatool" & linefeed & ¬
					"echo ''" & linefeed & ¬
					"if command -v ipatool &> /dev/null; then" & linefeed & ¬
					"    echo '✅ ipatool installed successfully!'" & linefeed & ¬
					"    echo ''" & linefeed & ¬
					"    echo 'You can now return to SDK Analyzer and try again.'" & linefeed & ¬
					"else" & linefeed & ¬
					"    echo '❌ Installation failed. Please install manually.'" & linefeed & ¬
					"fi" & linefeed & ¬
					"echo ''" & linefeed & ¬
					"echo 'Press any key to close...'" & linefeed & ¬
					"read -n 1 -s"

				-- Write install script to temp file
				set tempScript to "/tmp/sdk-analyzer-install-ipatool.sh"
				do shell script "cat > " & quoted form of tempScript & " << 'EOFSCRIPT'" & linefeed & installScript & linefeed & "EOFSCRIPT"
				do shell script "chmod +x " & quoted form of tempScript

				-- Open Terminal with install script
				do shell script "open -a Terminal " & quoted form of tempScript

				display notification "Follow the Terminal instructions to install" with title "SDK Analyzer"
			end if

			return
		else
			return -- User cancelled
		end if
	end if

	-- Check if ipatool is authenticated
	set isAuthenticated to false
	set currentEmail to ""

	try
		set authCheck to do shell script "cd " & quoted form of scriptDir & " && export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\" && ipatool auth info 2>&1"
		if authCheck contains "email=" then
			set isAuthenticated to true
			-- Extract email from output and strip ANSI color codes
			try
				set currentEmail to do shell script "echo " & quoted form of authCheck & " | grep -o 'email=[^ ]*' | cut -d= -f2 | sed 's/\\x1b\\[[0-9;]*m//g'"
			end try
		end if
	end try

	-- If not authenticated, prompt for Apple ID
	if not isAuthenticated then
		-- Prompt for email
		set authPrompt to "🔐 Apple ID Authentication Required" & return & return & ¬
			"To download iOS apps, you need to authenticate with your Apple ID." & return & return & ¬
			"Enter your Apple ID email address:"

		try
			set appleIDEmail to text returned of (display dialog authPrompt default answer "" buttons {"Cancel", "Next"} default button "Next" with icon note with title "Authentication Required")
		on error
			return -- User cancelled
		end try

		if appleIDEmail is "" then
			display dialog "Apple ID email is required to continue." buttons {"OK"} default button "OK" with icon stop with title "Error"
			return
		end if

		-- Prompt for password
		set passwordPrompt to "🔐 Apple ID Password" & return & return & ¬
			"Email: " & appleIDEmail & return & return & ¬
			"Enter your Apple ID password:"

		try
			set appleIDPassword to text returned of (display dialog passwordPrompt default answer "" buttons {"Cancel", "Authenticate"} default button "Authenticate" with icon note with title "Authentication Required" with hidden answer)
		on error
			return -- User cancelled
		end try

		if appleIDPassword is "" then
			display dialog "Password is required to continue." buttons {"OK"} default button "OK" with icon stop with title "Error"
			return
		end if

		-- Show authentication progress
		display dialog "🔄 Authenticating with Apple..." & return & return & ¬
			"Email: " & appleIDEmail & return & return & ¬
			"This may take a moment..." buttons {"Authenticating..."} default button 1 giving up after 2 with title "SDK Analyzer" with icon note

		-- Attempt authentication
		try
			set authCommand to "cd " & quoted form of scriptDir & " && export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\" && ipatool auth login --email " & quoted form of appleIDEmail & " --password " & quoted form of appleIDPassword & " 2>&1"
			set authResult to do shell script authCommand

			-- Check if 2FA is required
			if authResult contains "enter 2FA code" or authResult contains "two-factor" or authResult contains "verification code" then
				-- Prompt for 2FA code
				set twoFAPrompt to "🔐 Two-Factor Authentication" & return & return & ¬
					"A verification code has been sent to your device." & return & return & ¬
					"Enter the 6-digit code:"

				try
					set twoFACode to text returned of (display dialog twoFAPrompt default answer "" buttons {"Cancel", "Verify"} default button "Verify" with icon note with title "2FA Required")
				on error
					return -- User cancelled
				end try

				if twoFACode is "" then
					display dialog "2FA code is required to continue." buttons {"OK"} default button "OK" with icon stop with title "Error"
					return
				end if

				-- Authenticate with 2FA code
				display dialog "🔄 Verifying 2FA code..." buttons {"Verifying..."} default button 1 giving up after 2 with title "SDK Analyzer" with icon note

				set authCommand2FA to "cd " & quoted form of scriptDir & " && export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\" && ipatool auth login --email " & quoted form of appleIDEmail & " --password " & quoted form of appleIDPassword & " --auth-code " & quoted form of twoFACode & " 2>&1"
				do shell script authCommand2FA
			end if

			display notification "Successfully authenticated!" with title "SDK Analyzer"

		on error authError
			set errorMsg to "❌ Authentication Failed" & return & return & ¬
				"Could not authenticate with Apple ID." & return & return & ¬
				"Please check:" & return & ¬
				"• Email address is correct" & return & ¬
				"• Password is correct" & return & ¬
				"• Internet connection is active" & return & return & ¬
				"Error details:" & return & authError

			display dialog errorMsg buttons {"OK"} default button "OK" with icon stop with title "Authentication Failed"
			return
		end try
	else
		-- Show currently authenticated user
		if currentEmail is not "" then
			display notification "Authenticated as: " & currentEmail with title "SDK Analyzer"
		end if
	end if

	-- Get App Store URL from user
	set urlPrompt to "Enter the App Store URL:" & return & return & ¬
		"Example:" & return & ¬
		"https://apps.apple.com/us/app/example/id1234567890"

	if currentEmail is not "" then
		set urlPrompt to urlPrompt & return & return & "Authenticated as: " & currentEmail
	end if

	try
		set appStoreURL to text returned of (display dialog urlPrompt default answer "" buttons {"Cancel", "Analyze"} default button "Analyze" with icon note with title "iOS App Analysis")
	on error
		return -- User cancelled
	end try

	-- Validate URL
	if appStoreURL is "" then
		display dialog "Please enter a valid App Store URL." buttons {"OK"} default button "OK" with icon stop with title "Error"
		return
	end if

	if appStoreURL does not contain "apps.apple.com" then
		display dialog "Please enter a valid App Store URL (must contain 'apps.apple.com')." buttons {"OK"} default button "OK" with icon stop with title "Error"
		return
	end if

	-- Show progress notification
	display notification "Starting iOS app analysis..." with title "SDK Analyzer"

	-- Show informational dialog explaining the wait
	display dialog "🔍 Analyzing iOS App" & return & return & ¬
		"App Store URL provided" & return & return & ¬
		"This may take 2-5 minutes depending on app size." & return & return & ¬
		"Steps:" & return & ¬
		"1. Downloading app from App Store" & return & ¬
		"2. Extracting IPA file" & return & ¬
		"3. Analyzing frameworks and libraries" & return & ¬
		"4. Generating report" & return & return & ¬
		"⏳ Analysis is running in the background" & return & ¬
		"✓ Check notifications for progress updates" buttons {"Running..."} default button 1 giving up after 3 with title "SDK Analyzer" with icon note

	-- Send periodic notification during analysis
	display notification "Downloading and extracting app..." with title "SDK Analyzer" subtitle "Please wait..."

	-- Run the detection script
	try
		set analysisCommand to "cd " & quoted form of scriptDir & " && ./detect-sdk-ios.sh -u " & quoted form of appStoreURL & " 2>&1"
		set analysisOutput to do shell script analysisCommand

		-- Find the report file from the output
		set reportPath to ""
		try
			set reportPath to do shell script "echo " & quoted form of analysisOutput & " | grep -o 'Full report: .*' | sed 's/Full report: //' | sed $'s/\\x1b\\[[0-9;]*m//g'"
		end try

		-- Extract working directory path from output for cleanup
		set workDir to ""
		try
			set workDir to do shell script "echo " & quoted form of analysisOutput & " | grep -o 'Analysis Directory: .*' | sed 's/Analysis Directory: //' | head -1"
		end try

		-- Show success message
		set successMessage to "✅ Analysis Complete!" & return & return & ¬
			"The analysis has finished successfully." & return & return

		if reportPath is not "" then
			set successMessage to successMessage & "Report saved to:" & return & reportPath
			display dialog successMessage buttons {"Open Report", "Done"} default button "Open Report" with icon note with title "Success"

			set userChoice to button returned of result

			-- Offer to clean up temporary files
			if workDir is not "" then
				try
					set cleanupPrompt to "🗑️  Clean up temporary analysis files?" & return & return & ¬
						"This will delete:" & return & ¬
						workDir & return & return & ¬
						"The report file will be kept."

					display dialog cleanupPrompt buttons {"Keep Files", "Delete Temp Files"} default button "Delete Temp Files" with icon caution with title "Clean Up"

					if button returned of result is "Delete Temp Files" then
						do shell script "rm -rf " & quoted form of workDir
						display notification "Temporary files cleaned up successfully" with title "SDK Analyzer"
					end if
				end try
			end if

			-- Open report if user chose that option
			if userChoice is "Open Report" then
				do shell script "open " & quoted form of reportPath
			end if
		else
			display dialog successMessage buttons {"OK"} default button "OK" with icon note with title "Success"
		end if

	on error errMsg
		-- Show error message
		if errMsg contains "password token is expired" then
			set errorMessage to "❌ Authentication Error" & return & return & ¬
				"Your Apple ID authentication has expired." & return & return & ¬
				"Please run this command in Terminal:" & return & ¬
				"ipatool auth login --email your@email.com"
		else if errMsg contains "temporarily unavailable" then
			set errorMessage to "❌ Download Error" & return & return & ¬
				"The app could not be downloaded." & return & return & ¬
				"Possible reasons:" & return & ¬
				"• App not available in your region" & return & ¬
				"• App not previously downloaded with your Apple ID" & return & return & ¬
				"Try using an app you've already downloaded."
		else if errMsg contains "Homebrew not found" or errMsg contains "needs to be an Administrator" or errMsg contains "Installing Homebrew" then
			set errorMessage to "❌ Setup Required" & return & return & ¬
				"Homebrew and ipatool need to be installed first." & return & return & ¬
				"Please run this one-time setup in Terminal:" & return & return & ¬
				"1. Install Homebrew:" & return & ¬
				"   /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" & return & return & ¬
				"2. Install ipatool:" & return & ¬
				"   brew install ipatool" & return & return & ¬
				"3. Authenticate:" & return & ¬
				"   ipatool auth login --email your@email.com" & return & return & ¬
				"Then try this app again!"
		else
			set errorMessage to "❌ Analysis Failed" & return & return & ¬
				"An error occurred during analysis:" & return & return & ¬
				errMsg
		end if

		display dialog errorMessage buttons {"OK"} default button "OK" with icon stop with title "Error"
	end try

	display notification "Analysis complete!" with title "SDK Analyzer"
end analyzeIOS

-- Android Analysis Function
on analyzeAndroid()
	-- Ask user to choose APK file
	try
		set apkFile to choose file with prompt "Select an Android APK file:" of type {"com.android.package-archive", "public.data"}
	on error
		return -- User cancelled
	end try

	set apkPath to POSIX path of apkFile
	set apkName to name of (info for apkFile)

	-- Show progress notification
	display notification "Starting Android app analysis..." with title "SDK Analyzer"

	-- Show informational dialog explaining the wait
	display dialog "🔍 Analyzing Android App" & return & return & ¬
		"File: " & apkName & return & return & ¬
		"This may take 1-3 minutes depending on app size." & return & return & ¬
		"Please be patient..." & return & return & ¬
		"⏳ Analysis is running in the background" & return & ¬
		"✓ Check notifications for progress updates" & return & ¬
		"✓ You can continue using your Mac" buttons {"Running..."} default button 1 giving up after 3 with title "SDK Analyzer" with icon note

	-- Get the directory where this app is located
	-- The app bundle is at: /path/to/SDK Analyzer.app
	-- We need to get the directory containing the .app bundle
	set appPath to path to me
	set appPosixPath to POSIX path of appPath
	-- Remove trailing slash if present
	if appPosixPath ends with "/" then
		set appPosixPath to text 1 thru -2 of appPosixPath
	end if
	-- Get parent directory of the .app bundle
	set scriptDir to do shell script "dirname " & quoted form of appPosixPath

	-- Send periodic notifications during analysis
	display notification "Extracting APK and analyzing libraries..." with title "SDK Analyzer" subtitle "Please wait..."

	-- Run the detection script
	try
		set analysisCommand to "cd " & quoted form of scriptDir & " && ./detect-sdk-android.sh -f " & quoted form of apkPath & " 2>&1"
		set analysisOutput to do shell script analysisCommand

		-- Find the report file from the output
		set reportPath to ""
		try
			set reportPath to do shell script "echo " & quoted form of analysisOutput & " | grep -o 'Full report: .*' | sed 's/Full report: //' | sed $'s/\\x1b\\[[0-9;]*m//g'"
		end try

		-- Extract working directory path from output for cleanup
		set workDir to ""
		try
			set workDir to do shell script "echo " & quoted form of analysisOutput & " | grep -o 'Analysis Directory: .*' | sed 's/Analysis Directory: //' | head -1"
		end try

		-- Show success message
		set successMessage to "✅ Analysis Complete!" & return & return & ¬
			"The analysis has finished successfully." & return & return

		if reportPath is not "" then
			set successMessage to successMessage & "Report saved to:" & return & reportPath
			display dialog successMessage buttons {"Open Report", "Done"} default button "Open Report" with icon note with title "Success"

			set userChoice to button returned of result

			-- Offer to clean up temporary files
			if workDir is not "" then
				try
					set cleanupPrompt to "🗑️  Clean up temporary analysis files?" & return & return & ¬
						"This will delete:" & return & ¬
						workDir & return & return & ¬
						"The report file will be kept."

					display dialog cleanupPrompt buttons {"Keep Files", "Delete Temp Files"} default button "Delete Temp Files" with icon caution with title "Clean Up"

					if button returned of result is "Delete Temp Files" then
						do shell script "rm -rf " & quoted form of workDir
						display notification "Temporary files cleaned up successfully" with title "SDK Analyzer"
					end if
				end try
			end if

			-- Open report if user chose that option
			if userChoice is "Open Report" then
				do shell script "open " & quoted form of reportPath
			end if
		else
			display dialog successMessage buttons {"OK"} default button "OK" with icon note with title "Success"
		end if

	on error errMsg
		-- Show error message
		set errorMessage to "❌ Analysis Failed" & return & return & ¬
			"An error occurred during analysis:" & return & return & ¬
			errMsg

		display dialog errorMessage buttons {"OK"} default button "OK" with icon stop with title "Error"
	end try

	display notification "Analysis complete!" with title "SDK Analyzer"
end analyzeAndroid
