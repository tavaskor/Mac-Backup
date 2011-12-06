-- backup_automation, by Terry Vaskor

-- Make sure that the ability to do this is enabled on this computer first
tell application "System Events"
	if not UI elements enabled then
		display dialog "Error: UI Elements are not enabled, so this script cannot run.
		
Please enable them by selecting \"Enable access for assistive devices\" in the \"Universal Access\" section of \"System Preferences\"" buttons {"Ok"} with icon 2 giving up after 20
		
		-- System Preferences popup suggestion from http://homepage.mac.com/jkevinwolfe/otto/page3/page4/page4.html
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
		end tell
		return
	end if
end tell

doActionWithApp("iTunes", iTunes_backup)
doActionWithApp("Address Book", addressbook_backup)
doActionWithApp("iCal", iCal_backup)



on iTunes_backup()
	local appname
	set appname to "iTunes"
	menu_click({"iTunes", "File", "Library", "Export Library…"})
	tell application "System Events"
		delay 1
		keystroke "d" using command down
		delay 1
		tell window (appname) of process appname
			click text field 1
			keystroke (((appname & "_backup_" & year of (current date) as string) & "-" & month of (current date) as string) & "-" & day of (current date) as string)
			get UI elements
			click button "Save"
			delay 1
			if exists sheet 1 then
				click button "Replace" of sheet 1
			end if
		end tell
	end tell
end iTunes_backup


on iCal_backup()
	local appname
	set appname to "iCal"
	menu_click({appname, "File", "Export…", "iCal Archive…"})
	tell application "System Events"
		delay 1
		keystroke "d" using command down
		delay 1
		tell sheet 1 of window appname of process appname
			click text field 1
			keystroke "a" using command down
			keystroke (((appname & "_backup_" & year of (current date) as string) & "-" & month of (current date) as string) & "-" & day of (current date) as string)
			get UI elements
			click button "Save"
			delay 1
			if exists sheet 1 then
				click button "Replace" of sheet 1
			end if
		end tell
	end tell
end iCal_backup


on addressbook_backup()
	local appname
	set appname to "Address Book"
	menu_click({appname, "File", "Export…", "Address Book Archive…"})
	tell application "System Events"
		delay 1
		keystroke "d" using command down
		delay 1
		tell sheet 1 of window appname of process appname
			click text field 1
			keystroke "a" using command down
			keystroke (((appname & "_backup_" & year of (current date) as string) & "-" & month of (current date) as string) & "-" & day of (current date) as string)
			get UI elements
			click button "Save"
			delay 1
			if exists sheet 1 then
				click button "Replace" of sheet 1
			end if
		end tell
	end tell
end addressbook_backup



-- `doActionWithApp`, by Terry Vaskor, May 2011
--
-- Accepts two parameters: the name of an application, 
-- and a handler to run using that application.
-- The wrapper will ensure the application is activated,
-- and it will quit after completing the handler if it
-- was not previously running.
on doActionWithApp(appname, action)
	-- Launch the application if it's not already running
	set wasRunning to true
	if not appIsRunning(appname) then
		-- TODO: check for failure to activate?
		tell application appname to activate
		
		repeat until window appname of application appname exists
			delay 0.5
		end repeat
		set wasRunning to false
	else
		tell application appname to activate
	end if
	
	-- Now run the provided function on that application, based on suggestions
	-- from http://www.apeth.net/matt/unm/asph.html
	script doThis
		property theHandler : action
		theHandler()
	end script
	run doThis
	
	-- Close the application if it was not previously running
	if not wasRunning then
		tell application appname to quit
	end if
end doActionWithApp




-- From comments at http://codesnippets.joyent.com/posts/show/1124
on appIsRunning(appname)
	tell application "System Events" to (name of processes) contains appname
end appIsRunning




-- Helper pair from http://hints.macworld.com/article.php?story=20060921045743404
-- `menu_click`, by Jacob Rus, September 2006
-- 
-- Accepts a list of form: `{"Finder", "View", "Arrange By", "Date"}`
-- Execute the specified menu item.  In this case, assuming the Finder 
-- is the active application, arranging the frontmost folder by date.

on menu_click(mList)
	local appname, topMenu, r
	
	-- Validate our input
	if mList's length < 3 then error "Menu list is not long enough"
	
	-- Set these variables for clarity and brevity later on
	set {appname, topMenu} to (items 1 through 2 of mList)
	set r to (items 3 through (mList's length) of mList)
	
	-- This overly-long line calls the menu_recurse function with
	-- two arguments: r, and a reference to the top-level menu
	tell application "System Events" to my menu_click_recurse(r, ((process appname)'s ¬
		(menu bar 1)'s (menu bar item topMenu)'s (menu topMenu)))
end menu_click

on menu_click_recurse(mList, parentObject)
	local f, r
	
	-- `f` = first item, `r` = rest of items
	set f to item 1 of mList
	if mList's length > 1 then set r to (items 2 through (mList's length) of mList)
	
	-- either actually click the menu item, or recurse again
	tell application "System Events"
		if mList's length is 1 then
			click parentObject's menu item f
		else
			my menu_click_recurse(r, (parentObject's (menu item f)'s (menu f)))
		end if
	end tell
end menu_click_recurse
