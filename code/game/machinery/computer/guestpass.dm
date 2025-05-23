/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to station areas."
	icon_state = "guest"

	var/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/reason = "NOT SPECIFIED"

/obj/item/card/id/guest/GetAccess()
	if (world.time > expiration_time)
		return access
	else
		return temp_access

/obj/item/card/id/guest/get_examine_text(mob/user)
	. = ..()
	if (world.time < expiration_time)
		. += SPAN_NOTICE("This pass expires at [worldtime2text(expiration_time)].")
	else
		. += SPAN_WARNING("It expired at [worldtime2text(expiration_time)].")

/obj/item/card/id/guest/read()
	if (world.time > expiration_time)
		to_chat(usr, SPAN_NOTICE("This pass expired at [worldtime2text(expiration_time)]."))
	else
		to_chat(usr, SPAN_NOTICE("This pass expires at [worldtime2text(expiration_time)]."))

	to_chat(usr, SPAN_NOTICE("It grants access to following areas:"))
	for (var/A in temp_access)
		to_chat(usr, SPAN_NOTICE("[get_access_desc(A)]."))
	to_chat(usr, SPAN_NOTICE("Issuing reason: [reason]."))
	return

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/structure/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	density = FALSE


	var/obj/item/card/id/giver
	var/list/accesses = list()
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs

/obj/structure/machinery/computer/guestpass/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/card/id))
		if(!giver)
			if(user.drop_held_item())
				O.forceMove(src)
				giver = O
				updateUsrDialog()
		else
			to_chat(user, SPAN_WARNING("There is already ID card inside."))

/obj/structure/machinery/computer/guestpass/attack_remote(mob/user as mob)
	return attack_hand(user)

/obj/structure/machinery/computer/guestpass/attack_hand(mob/user as mob)
	if(..())
		return

	user.set_interaction(src)
	var/dat

	if (mode == 1) //Logs
		dat += "<h3>Activity log</h3><br>"
		for (var/entry in internal_log)
			dat += "[entry]<br><hr>"
		dat += "<a href='byond://?src=\ref[src];action=print'>Print</a><br>"
		dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"
	else
		dat += "<h3>Guest pass terminal</h3><br>"
		dat += "<a href='byond://?src=\ref[src];mode=1'>View activity log</a><br><br>"
		dat += "Issuing ID: <a href='byond://?src=\ref[src];action=id'>[giver]</a><br>"
		dat += "Issued to: <a href='byond://?src=\ref[src];choice=giv_name'>[giv_name]</a><br>"
		dat += "Reason:  <a href='byond://?src=\ref[src];choice=reason'>[reason]</a><br>"
		dat += "Duration (minutes):  <a href='byond://?src=\ref[src];choice=duration'>[duration] m</a><br>"
		dat += "Access to areas:<br>"
		if (giver && giver.access)
			for (var/A in giver.access)
				var/area = get_access_desc(A)
				if (A in accesses)
					area = "<b>[area]</b>"
				dat += "<a href='byond://?src=\ref[src];choice=access;access=[A]'>[area]</a><br>"
		dat += "<br><a href='byond://?src=\ref[src];action=issue'>Issue pass</a><br>"

	user << browse(dat, "window=guestpass;size=400x520")
	onclose(user, "guestpass")


/obj/structure/machinery/computer/guestpass/Topic(href, href_list)
	if(..())
		return
	usr.set_interaction(src)
	if (href_list["mode"])
		mode = text2num(href_list["mode"])

	if (href_list["choice"])
		switch(href_list["choice"])
			if ("giv_name")
				var/nam = stripped_input("Person pass is issued to", "Name", giv_name)
				if (nam)
					giv_name = nam
			if ("reason")
				var/reas = stripped_input(usr,"Reason why pass is issued", "Reason", reason)
				if(reas)
					reason = reas
			if ("duration")
				var/dur = tgui_input_number(usr, "Duration (in minutes) during which pass is valid (up to 30 minutes).", "Duration", 5, 30, 1)
				if (dur)
					if (dur > 0 && dur <= 30)
						duration = dur
					else
						to_chat(usr, SPAN_WARNING("Invalid duration."))
			if ("access")
				var/A = text2num(href_list["access"])
				if (A in accesses)
					accesses.Remove(A)
				else
					accesses.Add(A)
	if (href_list["action"])
		switch(href_list["action"])
			if ("id")
				if (giver)
					if(ishuman(usr))
						giver.forceMove(usr.loc)
						if(!usr.get_active_hand())
							usr.put_in_hands(giver)
						giver = null
					else
						giver.forceMove(src.loc)
						giver = null
					accesses.Cut()
				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/card/id))
						if(usr.drop_held_item())
							I.forceMove(src)
							giver = I
				updateUsrDialog()

			if ("print")
				var/dat = "<h3>Activity log of guest pass terminal</h3><br>"
				for (var/entry in internal_log)
					dat += "[entry]<br><hr>"
				//to_chat(usr, "Printing the log, standby...")
				//sleep(50)
				var/obj/item/paper/P = new/obj/item/paper( loc )
				P.name = "activity log"
				P.info = dat

			if ("issue")
				if (giver)
					var/number = add_leading("[rand(0,9999)]", 4)
					var/entry = "\[[worldtime2text()]\] Pass #[number] issued by [giver.registered_name] ([giver.assignment]) to [giv_name]. Reason: [reason]. Grants access to following areas: "
					for (var/i=1 to length(accesses))
						var/A = accesses[i]
						if (A)
							var/area = get_access_desc(A)
							entry += "[i > 1 ? ", [area]" : "[area]"]"
					entry += ". Expires at [worldtime2text(world.time + duration*10*60)]."
					internal_log.Add(entry)

					var/obj/item/card/id/guest/pass = new(src.loc)
					pass.temp_access = accesses.Copy()
					pass.registered_name = giv_name
					pass.expiration_time = world.time + duration*10*60
					pass.reason = reason
					pass.name = "guest pass #[number]"
				else
					to_chat(usr, SPAN_DANGER("Cannot issue pass without issuing ID."))
	updateUsrDialog()
	return
