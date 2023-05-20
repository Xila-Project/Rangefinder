import This
import Graphics

var Window = This.Get_Window()

Window.Set_Title("Hello World")

Label = Graphics.Label_Type()
Label.Create(Window.Get_Body())
Label.Set_Text("Hello World")
Label.Set_Alignment(Graphics.Alignment_Center)

while true
    # Do stuff

    if This.Instruction_Available() > 0
        Instruction = This.Get_Instruction()
   
        # Do stuff with instruction
    end

    This.Delay(50)
end