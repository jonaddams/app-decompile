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
	-- Get App Store URL from user
	set urlPrompt to "Enter the App Store URL:" & return & return & ¬
		"Example:" & return & ¬
		"https://apps.apple.com/us/app/example/id1234567890"

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
