;****************************************
; LGUI2Scaling.iss
; LavishGUI2 UI Scaling Functions
;
; This file contains functions for scaling LGUI2 JSON UI definitions
; to different sizes while maintaining proper layout and proportions.
;
; USAGE INSTRUCTIONS:
; -------------------
; To add UI scaling to your LGUI2-based script, follow these steps:
;
; 1. Include this file at the top of your script:
;    #include ${LavishScript.HomeDirectory}/Scripts/LGUI2Scaling.iss
;
; 2. In your main() function, add scaling logic before loading your UI:
;
;    function main()
;    {
;        ; Set your desired scale factor (1.0 = no scaling, 2.0 = 2x larger, 0.5 = half size)  [Do not edit anything below this variable setting]
;        variable float uiScale = 1.0
;
;        ; Only scale if not 1.0 (skip scaling for default size)
;        if (!${uiScale.Equal[1.0]})
;        {
;            ; DebugScaling variable is set in LGUI2Scaling.iss
;            if ${DebugScaling}
;                echo Preprocessing UI with ${uiScale}x scale factor...
;
;            ; Call scaling function: ScaleUIJson(inputFile, outputFile, scaleFactor)
;            call ScaleUIJson "${LavishScript.HomeDirectory}/Scripts/YourScript/YourUI.json" "${LavishScript.HomeDirectory}/Scripts/YourScript/YourUI_Scaled.json" ${uiScale}
;
;            ; Load the scaled version
;            LGUI2:LoadPackageFile["${LavishScript.HomeDirectory}/Scripts/YourScript/YourUI_Scaled.json"]
;        }
;        else
;        {
;            ; Load original unscaled version
;            LGUI2:LoadPackageFile["${LavishScript.HomeDirectory}/Scripts/YourScript/YourUI.json"]
;        }
;
;        ; Continue with rest of your script...
;    }
;
; 3. To enable debug output, set DebugScaling=TRUE in this file (line 48)
;
; NOTES:
; - The scaling preserves layout by converting percentage positions to absolute pixels
; - Buttons are scaled to 85% width to prevent overlap in multi-column layouts
; - Fonts are automatically scaled and added to elements that need them
; - Textblock labels are automatically left-aligned for proper positioning
;
;****************************************

; Debug flag for UI scaling messages (set to TRUE to see scaling debug output)
variable bool DebugScaling=FALSE

function ScaleUIJson(string inputFile, string outputFile, float scaleFactor)
{
    variable jsonvalue joTemp
    variable jsonvalue jo
    variable string jsonText

    if ${DebugScaling}
        echo ScaleJSON: Loading ${inputFile}

    ; First load with ParseFile to get the JSON
    joTemp:ParseFile["${inputFile}"]

    if !${joTemp.Type.Equal[object]}
    {
        echo ERROR: Could not load JSON file ${inputFile}
        return
    }

    ; Convert to string
    jsonText:Set["${joTemp~}"]

    if ${DebugScaling}
        echo ScaleJSON: JSON loaded, size ${jsonText.Length} chars

    ; Now reload with SetValue so we can use iterator
    jo:SetValue["${jsonText.Escape}"]

    if !${jo.Type.Equal[object]}
    {
        echo ERROR: Could not parse JSON - Type: ${jo.Type}
        return
    }

    if ${DebugScaling}
        echo ScaleJSON: Scaling by factor ${scaleFactor}

    ; Manually scale the JSON structure - can't use iterator
    ; Process the elements array
    if ${jo.Has[elements]}
    {
        call ScaleElementsArray jo ${scaleFactor}
    }

    if ${DebugScaling}
        echo ScaleJSON: Writing to ${outputFile}

    ; Write the scaled JSON to output file
    jo:WriteFile["${outputFile}",multiline]

    if ${DebugScaling}
        echo ScaleJSON: Complete!
}

function ScaleElementsArray(jsonvalueref rootObj, float scaleFactor)
{
    ; Use ForEach to iterate the elements array
    rootObj.Get[elements]:ForEach["call ScaleElement ForEach.Value ${scaleFactor}"]
}

function ScaleElement(jsonvalueref elem, float scaleFactor)
{
    variable float newVal
    variable string elemType
    variable float widthFactor

    ; Scale width - but use smaller factor for buttons to prevent overlap
    if ${elem.Has[width]}
    {
        widthFactor:Set[${scaleFactor}]

        ; For buttons and textblocks, use larger width to fit scaled text
        if ${elem.Has[type]}
        {
            elemType:Set["${elem.Get[type]}"]
            if ${elemType.Equal[button]}
            {
                ; Buttons use 85% to fit text while leaving spacing between columns
                widthFactor:Set[${scaleFactor} * 0.85]
            }
            elseif ${elemType.Equal[textblock]}
            {
                ; Textblocks use full scale factor (they're just labels)
                widthFactor:Set[${scaleFactor}]
            }
        }

        newVal:Set[${elem.Get[width]} * ${widthFactor}]
        elem:SetInteger[width,${newVal.Int}]
    }
    if ${elem.Has[height]}
    {
        newVal:Set[${elem.Get[height]} * ${scaleFactor}]
        elem:SetInteger[height,${newVal.Int}]
    }

    ; Check if this is a window type element (to preserve window position)
    variable bool isWindow=FALSE
    if ${elem.Has[type]}
    {
        elemType:Set["${elem.Get[type]}"]
        if ${elemType.Equal[window]}
        {
            isWindow:Set[TRUE]
        }
    }

    ; Handle x position - convert percentages to absolute pixels
    ; Skip scaling for main window elements to preserve screen position
    if ${elem.Has[x]} && !${isWindow}
    {
        variable string xValue
        xValue:Set["${elem.Get[x]}"]

        ; Check if it's a percentage
        if ${xValue.Find[%](exists)}
        {
            ; Convert percentage to absolute pixels based on scaled window width
            ; Original window is 330px, scaled window is 330 * scaleFactor
            variable float percent
            variable float windowWidth
            percent:Set[${xValue.Left[${Math.Calc[${xValue.Length}-1]}]}]
            windowWidth:Set[${Math.Calc[330 * ${scaleFactor}]}]
            newVal:Set[${Math.Calc[${windowWidth} * ${percent} / 100]}]
            elem:SetInteger[x,${newVal.Int}]
        }
        else
        {
            ; It's already an absolute pixel value
            ; Scale normally - textblocks should align with their corresponding textboxes
            newVal:Set[${elem.Get[x]} * ${scaleFactor}]
            elem:SetInteger[x,${newVal.Int}]
        }
    }

    ; Handle y position - convert percentages to absolute pixels
    ; Skip scaling for main window elements to preserve screen position
    if ${elem.Has[y]} && !${isWindow}
    {
        variable string yValue
        yValue:Set["${elem.Get[y]}"]

        ; Check if it's a percentage
        if ${yValue.Find[%](exists)}
        {
            ; Convert percentage to absolute pixels based on scaled window height
            ; Original window is 465px, scaled window is 465 * scaleFactor
            variable float yPercent
            variable float windowHeight
            yPercent:Set[${yValue.Left[${Math.Calc[${yValue.Length}-1]}]}]
            windowHeight:Set[${Math.Calc[465 * ${scaleFactor}]}]
            newVal:Set[${Math.Calc[${windowHeight} * ${yPercent} / 100]}]
            elem:SetInteger[y,${newVal.Int}]
        }
        else
        {
            ; It's an absolute pixel value, scale it
            newVal:Set[${elem.Get[y]} * ${scaleFactor}]
            elem:SetInteger[y,${newVal.Int}]
        }
    }

    ; Handle font object (scale font height - LGUI2 uses "height" not "size")
    ; If element has font but no height, add default height first
    if ${elem.Has[font]}
    {
        if ${elem.Get[font].Type.Equal[object]}
        {
            ; Add default font height if not present (LGUI2 standard)
            if !${elem.Get[font].Has[height]}
            {
                elem.Get[font]:SetInteger[height,12]
            }

            ; Now scale the font height
            if ${elem.Get[font].Has[height]}
            {
                variable float fontHeight
                fontHeight:Set[${elem.Get[font].Get[height]} * ${scaleFactor}]
                elem.Get[font]:SetInteger[height,${fontHeight.Int}]
            }
        }
    }
    ; If element has no font at all but is a type that should have text, add default font
    elseif ${elem.Has[type]}
    {
        elemType:Set["${elem.Get[type]}"]

        ; Add default font to text-bearing elements (LGUI2 uses "height" property)
        if ${elemType.Equal[button]} || ${elemType.Equal[textblock]} || ${elemType.Equal[textbox]} || ${elemType.Equal[tab]} || ${elemType.Equal[tabcontrol]} || ${elemType.Equal[window]}
        {
            variable jsonvalue defaultFont={}
            defaultFont:SetInteger[height,${Math.Calc[12 * ${scaleFactor}].Int}]
            elem:Set[font,"${defaultFont~}"]
        }
    }

    ; Fix textblock horizontal alignment - labels should be left-aligned
    if ${elem.Has[type]}
    {
        elemType:Set["${elem.Get[type]}"]
        if ${elemType.Equal[textblock]} && ${elem.Has[horizontalAlignment]}
        {
            ; Change center alignment to left for proper label positioning
            variable string alignment
            alignment:Set["${elem.Get[horizontalAlignment]}"]
            if ${alignment.Equal[center]}
            {
                elem:SetString[horizontalAlignment,"left"]
            }
        }
    }

    ; Handle nested content object (tabcontrol, panel, etc.)
    if ${elem.Has[content]}
    {
        ; Only recurse if content is a jsonobject (not a string like button text)
        if ${elem.Get[content](type).Name.Equal[jsonobject]}
        {
            call ScaleElement elem.Get[content] ${scaleFactor}
        }
    }

    ; Handle children array
    if ${elem.Has[children]}
    {
        if ${elem.Get[children].Type.Equal[array]}
        {
            elem.Get[children]:ForEach["call ScaleElement ForEach.Value ${scaleFactor}"]
        }
    }

    ; Handle tabs array
    if ${elem.Has[tabs]}
    {
        if ${elem.Get[tabs].Type.Equal[array]}
        {
            elem.Get[tabs]:ForEach["call ScaleElement ForEach.Value ${scaleFactor}"]
        }
    }
}
