Widget {
    id: subfl
    //visual
    Widget {}
    Widget {
        ZynAnalogFilter {}
        ZynFilterEnv {extern: subfl.extern+"FilterEnvelope/"}
        function layout(l) {
            Draw::Layout::hpack(l, self_box(l), chBoxes(l))
        }
    }
    function layout(l) {
        Draw::Layout::vfill(l, self_box(l), chBoxes(l), [0.6, 0.4])
    }
}
