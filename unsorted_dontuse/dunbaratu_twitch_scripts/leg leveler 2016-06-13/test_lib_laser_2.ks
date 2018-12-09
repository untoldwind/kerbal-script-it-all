run once lib_laser.

clearscreen.

set visualnorm to vecdraw( V(0,0,0), v(0,0,0), magenta, "", 1, true).

print "Just hit ctrl-C to quit this test.".

lib_laser["normal_setup"]("slop").
until false {
  local hits is lib_laser["get_normal"]().

  if hits[1]:mag = 0 {
    print "THERE IS NO HIT                     " at (5,5).
    set visualnorm:show to false.
  } else {
    local vecdraw_scale is hits[1]:mag / 5.
    set visualnorm:start to hits[1].
    set visualnorm:vec to vecdraw_scale*hits[0].
    set visualnorm:width to vecdraw_scale / 10.
    set visualnorm:show to true.

    print "slope in degrees is " + round( vang(hits[0],ship:up:vector), 1) + "     " at (5,5).
  }
  wait 0.
}
