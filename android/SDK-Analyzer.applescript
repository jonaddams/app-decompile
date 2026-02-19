-- SDK Analyzer - Desktop Application
-- A user-friendly GUI for analyzing mobile apps for SDK detection

on run
	-- Display welcome dialog
	set welcomeMessage to "SDK Analyzer" & return & return & ¬
		"This tool analyzes mobile apps to detect SDKs and frameworks." & return & return & ¬
		"Select the platform you want to analyze:"

	set platformChoice to button returned of (display dialog welcomeMessage buttons {"Cancel", "Analyze Android App"} default button "Analyze Android App" with icon note with title "SDK Analyzer")

	if platformChoice is "Analyze Android App" then
		analyzeAndroid()
	end if
end run

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

	-- Check if detection script exists
	try
		do shell script "test -f " & quoted form of scriptDir & "/detect-sdk-android.sh"
	on error
		-- Check if we're in App Translocation
		set isTranslocated to scriptDir contains "/AppTranslocation/"

		if isTranslocated then
			set missingScriptMsg to "❌ macOS Security Restriction" & return & return & ¬
				"macOS has moved this app to a secure temporary location." & return & ¬
				"This prevents it from finding the required scripts." & return & return & ¬
				"To fix this:" & return & return & ¬
				"EASIEST: Double-click \"Remove-Quarantine.command\"" & return & ¬
				"in the same folder, then try opening this app again." & return & return & ¬
				"OR via Terminal:" & return & ¬
				"1. Close this app" & return & ¬
				"2. Open Terminal and run:" & return & ¬
				"   xattr -cr \"path/to/SDK Analyzer.app\"" & return & ¬
				"3. Open SDK Analyzer.app again"
		else
			set missingScriptMsg to "❌ Setup Error" & return & return & ¬
				"The analysis script is missing." & return & return & ¬
				"SDK Analyzer.app must be in the same folder as:" & return & ¬
				"• detect-sdk-ios.sh" & return & ¬
				"• detect-sdk-android.sh" & return & ¬
				"• competitors.txt" & return & ¬
				"• library-info.txt" & return & return & ¬
				"Please:" & return & ¬
				"1. Extract the complete SDK-Analyzer-v1.0.zip" & return & ¬
				"2. Keep all files together in the same folder" & return & ¬
				"3. Run SDK Analyzer.app from that folder" & return & return & ¬
				"Current location: " & scriptDir
		end if

		display dialog missingScriptMsg buttons {"OK"} default button "OK" with icon stop with title "Setup Error"
		return
	end try

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
