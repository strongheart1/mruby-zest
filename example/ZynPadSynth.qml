Widget {
    id: center

    function layout(l)
    {
        selfBox = l.genBox :zynCenter, center
        headBox  = header.layout(l)
        swapBox  = swap.layout(l)

        l.contains(selfBox, headBox)
        l.contains(selfBox, swapBox)

        #Global Optimizatoin
        l.topOf(headBox, swapBox)

        l.sheq([headBox.h, selfBox.h], [1, -0.05], 0)

        selfBox
    }

    function apply()
    {
        $remote.action(center.extern+"prepare")
    }
    TabGroup {
        id: header
        TabButton { label: "harmonic structure";}
        TabButton { label: "oscillator";}
        TabButton { label: "envelopes & lfos"}

        ApplyButton {
            layoutOpts: [:no_constraint];
            label: "   apply"
            extern: center.extern + "needPrepare"
            whenValue: lambda {center.apply() }
        }
        CopyButton {
            id: copy
            extern: center.extern
        }
        PasteButton {
            id: paste
            extern: center.extern
        }
        function gen_weights()
        {
            total   = 0
            weights = []
            children.each do |ch|
                scale = 100
                $vg.font_size scale
                weight   = $vg.text_bounds(0, 0, ch.label.upcase + "  ")
                weights << weight
                total   += weight
            end
            return total, weights
        }

        function layout(l)
        {
            selfBox = l.genBox :zynCenterHeader, self
            prev = nil

            (total, weights) = gen_weights

            children.each_with_index do |ch, idx|
                box = ch.layout(l)
                l.contains(selfBox,box)

                if(idx < 3)
                    l.sh([box.w, selfBox.w], [1, -(1-1e-4)*weights[idx]/total], 0)

                    #add in the aspect constraint
                    l.aspect(box, 100, weights[idx])
                elsif(idx == 3)
                    l.aspect(box, 100, weights[idx])
                    l.weak(box.x)
                end

                if(prev)
                    l.rightOf(prev, box)
                end
                prev = box
            end
            selfBox
        }

        function set_tab(wid)
        {
            selected = get_tab wid

            #Define a mapping from tabs to values
            mapping = {0 => :harmonics,
                       1 => :oscil,
                       2 => :global_pad}
            root.set_view_pos(:subview, mapping[selected])
            root.change_view
        }

    }
    function get_voice() { root.get_view_pos(:voice) }
    function get_part()  { root.get_view_pos(:part)  }
    function get_kit()   { root.get_view_pos(:kit)   }

    function onSetup(old=nil)
    {
        return if swap.content.nil?
        set_view
    }

    function set_view()
    {
        subview = root.get_view_pos(:subview)

        mapping = {:harmonics   => Qml::ZynPadHarmonics,
                   :oscil       => Qml::ZynOscil,
                   :global_pad  => Qml::ZynPadGlobal}
        base = center.extern
        ext     = {:harmonics  => "",
                   :oscil      => "oscilgen/",
                   :global_pad => ""}
        tabid   = {:harmonics  => 0,
                   :oscil      => 1,
                   :global_pad => 2}
        if(!mapping.include?(subview))
            subview = :oscil
            root.set_view_pos(:subview, :oscil)
        end


        copy.extern  = base + ext[subview]
        paste.extern = base + ext[subview]
        swap.extern  = base + ext[subview]
        swap.content = mapping[subview]
        header.children[tabid[subview]].value = true
    }

    Swappable { id: swap }
}
