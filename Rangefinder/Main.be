# - Importing modules

import Graphics
import This
import Pin
import System
import string
import Softwares

# - Global variables

# - - Graphics

var Window = This.Get_Window()
var Software = This.Get_This()

var First_Row = Graphics.Object_Type()
var Second_Row = Graphics.Object_Type()
var Third_Row = Graphics.Object_Type()

var Enable_Label = Graphics.Label_Type()
var Enable_Switch = Graphics.Switch_Type()

var Plus_Echo_Button = Graphics.Button_Type()
var Minus_Echo_Button = Graphics.Button_Type()
var Plus_Trigger_Button = Graphics.Button_Type()
var Minus_Trigger_Button = Graphics.Button_Type()

var Echo_Pin_Spinbox = Graphics.Spinbox_Type()
var Trigger_Pin_Spinbox = Graphics.Spinbox_Type()

var Distance_Label = Graphics.Label_Type()

# - - Others

var Next_Refresh = 0
var Execute = true

# - Functions

# This function is used to create a row.
def Set_Interface_Row(Parent, Row)
    Row.Create(Parent)
    Row.Set_Height(Graphics.Size_Content)
    Row.Set_Width(Graphics.Get_Percentage(100))
    Row.Set_Flex_Flow(Graphics.Flex_Flow_Row)
    Row.Set_Flex_Alignment(Graphics.Flex_Alignment_Space_Evenly, Graphics.Flex_Alignment_Center, Graphics.Flex_Alignment_Center)
end

# This function is used to create a button.
def Set_Interface_Button(Parent, Button, Text)
    Button.Create(Parent)
    Button.Add_Event(Software, Graphics.Event_Code_Clicked)

    Label = Graphics.Label_Type()
    Label.Create(Button)
    Label.Set_Text(Text)
end

# This function is used to create a spinbox and its buttons.
def Set_Interface_Spinbox(Parent, Spinbox, Text, Minus_Button, Plus_Button)	
	Label = Graphics.Label_Type()
	Label.Create(Parent)
	Label.Set_Text(Text)
	
	Set_Interface_Button(Parent, Minus_Button, "-")

	Spinbox.Create(Parent)
	Spinbox.Set_Range(0, 46)
	Spinbox.Set_Digit_Format(2, 0)
	Spinbox.Set_Rollover(true)
	Spinbox.Set_Step(1)
	Spinbox.Add_Event(Software, Graphics.Event_Code_Value_Changed)

	Set_Interface_Button(Parent, Plus_Button, "+")
end

# This function is used to get the distance measured by the rangefinder.
def Get_Distance()
	# - Set pins mode
	Pin.Set_Mode(Trigger_Pin_Spinbox.Get_Value(), Pin.Mode_Output)
	Pin.Set_Mode(Echo_Pin_Spinbox.Get_Value(), Pin.Mode_Input)

	# - Send a pulse
	Pin.Digital_Write(Trigger_Pin_Spinbox.Get_Value(), Pin.Digital_State_Low)
	This.Delay_Microseconds(2)
	Pin.Digital_Write(Trigger_Pin_Spinbox.Get_Value(), Pin.Digital_State_High)
	This.Delay_Microseconds(10)
	Pin.Digital_Write(Trigger_Pin_Spinbox.Get_Value(), Pin.Digital_State_Low)

	Duration = Pin.Get_Pulse_In(Echo_Pin_Spinbox.Get_Value(), Pin.Digital_State_High, 1000000)	# Get the time it takes for the pulse to return.

	return Duration * 0.0343 / 2	# Since the speed of sound is 343 m/s, the distance is equal to the duration of the pulse divided by 2 and multiplied by 0.0343.
end

# This function is used to create the graphical interface.
def Set_Interface()
	# - Window
	Window.Set_Title("Rangefinder")

	Window_Body = Window.Get_Body()
	Window_Body.Set_Flex_Flow(Graphics.Flex_Flow_Column)
	Window_Body.Set_Flex_Alignment(Graphics.Flex_Alignment_Space_Evenly, Graphics.Flex_Alignment_Center, Graphics.Flex_Alignment_Center)

	# - Body

	# - - Enable

	Set_Interface_Row(Window_Body, First_Row)
	Enable_Label.Create(First_Row)
	Enable_Label.Set_Text("Enable : ")
	Enable_Switch.Create(First_Row)
	Enable_Switch.Clear_State(Graphics.State_Checked)

	Set_Interface_Row(Window_Body, Second_Row)
	
	Set_Interface_Spinbox(Second_Row, Echo_Pin_Spinbox, "Echo pin : ", Minus_Echo_Button, Plus_Echo_Button)
	Echo_Pin_Spinbox.Set_Value(11)
	
	Set_Interface_Row(Window_Body, Third_Row)

	Set_Interface_Spinbox(Third_Row, Trigger_Pin_Spinbox, "Trigger pin : ", Minus_Trigger_Button, Plus_Trigger_Button)
	Trigger_Pin_Spinbox.Set_Value(12)
	
	Distance_Label.Create(Window_Body)
	Distance_Label.Set_Text("Distance : 0 cm")
end

# This function is used to execute the program.
def Execute_Instruction(Instruction)
	# - Graphics instructions
	if Instruction.Get_Sender() == Graphics.Get_Pointer()
		Target = Instruction.Graphics_Get_Target()
		if Target == Plus_Echo_Button
			Echo_Pin_Spinbox.Increment()
		elif Target == Minus_Echo_Button
			Echo_Pin_Spinbox.Decrement()
		elif Target == Plus_Trigger_Button
			Trigger_Pin_Spinbox.Increment()
		elif Target == Minus_Trigger_Button
			Trigger_Pin_Spinbox.Decrement()
		elif Target == Trigger_Pin_Spinbox
			Pin.Set_Mode(Trigger_Pin_Spinbox.Get_Value(), Pin.Mode_Output)
		elif Target == Echo_Pin_Spinbox
			Pin.Set_Mode(Echo_Pin_Spinbox.Get_Value(), Pin.Mode_Input)
		end
	# - Software instructions
	elif Instruction.Get_Sender() == Softwares.Get_Pointer()
		if Instruction.Softwares_Get_Code() == Softwares.Event_Code_Close
			Execute = false
		end
	end
end

# - Main program

Set_Interface()

while Execute
	# - Execute instructions
	if This.Instruction_Available() > 0
		Execute_Instruction(This.Get_Instruction())
	end

	# - Refresh the distance if the switch is enabled.
	if Enable_Switch.Has_State(Graphics.State_Checked) == true
		if System.Get_Up_Time_Milliseconds() > Next_Refresh
			Distance = Get_Distance()
			# According to the datasheet, the HC-SR04 can measure from 2cm to 400cm
			if Distance > 400
				Distance_Label.Set_Text("Distance : too long")
			elif Distance < 2
				Distance_Label.Set_Text("Distance : too short")
			# If the distance is between 2 and 100 cm, display it in cm
			elif Distance < 100
				# Round the distance to 1 digit since the sensor is precise to 0.3 cm
				Distance_Label.Set_Text("Distance : " + string.format("%.1f", (Distance)) + " cm")
			# If the distance is between 100 and 400 cm, display it in m
			else
				# Round the distance to 3 digits since the sensor is precise to 0.003 m
				Distance_Label.Set_Text("Distance : " + string.format("%.3f", (Distance / 100)) + " m")			
			end	
			# Refresh every 0.5 second
			Next_Refresh = System.Get_Up_Time_Milliseconds() + 500
		end
	end

	This.Delay(50)	# Delay to reduce CPU usage
end

