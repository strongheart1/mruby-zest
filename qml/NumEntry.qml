Widget {
    id: numentry
    property Function whenValue: nil
    property Int      value: 0
    property Object   valueRef: nil

    onExtern: {
        numentry.valueRef = OSC::RemoteParam.new($remote, numentry.extern)
        numentry.valueRef.mode     = :full
        numentry.valueRef.callback = Proc.new {|x| numentry.setValue(x)}

    }

    function class_name() {"num_entry"}
    function layout(l)
    {
        t = widget.class_name.to_sym
        selfBox = l.genBox t, self

        #Assume all digit bounding boxes are roughly the same
        scale = 100
        $vg.font_size scale
        bb = $vg.text_bounds(0, 0, "- 9999 +")
        l.sh([selfBox.w, selfBox.h], [-1.0, bb/scale], 0)

        selfBox
    }
    function draw(vg)
    {
        textHeight = 0.8
        vg.path do
            vg.rect(0, 0, w, h)
            paint = vg.linear_gradient(0,0,0,h,
                Theme::ButtonGrad1, Theme::ButtonGrad2)
            vg.fill_paint paint
            vg.fill
            vg.stroke_width 1
            vg.stroke
        end

        vg.path do
            vg.move_to(0.2*w, 0*h)
            vg.line_to(0.2*w, 1*h)
            vg.move_to(0.8*w, 0*h)
            vg.line_to(0.8*w, 1*h)
            vg.stroke
        end

        vg.font_face("bold")
        vg.font_size h*textHeight
        vg.fill_color Theme::TextColor
        vg.text_align NVG::ALIGN_CENTER | NVG::ALIGN_MIDDLE
        vg.text(0.1*w,h/2,"-")
        vg.text(0.9*w,h/2,"+")
        vg.text(0.5*w,h/2,self.value.to_s)

        #background color("54321")
        #background color("54321")
    }

    function setValue(val)
    {
        self.value = val
        damage_self
    }

    function updatePos(delta)
    {
        self.value += delta
        if(self.valueRef)
            self.valueRef.value = self.value
        end
        damage_self
    }

    function onScroll(ev)
    {
        updatePos(+1) if ev.dy > 0
        updatePos(-1) if ev.dy < 0
    }
}
