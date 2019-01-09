function vacBalance {
    CLEARSCREEN.
    CLEARVECDRAWS().

    LIST ENGINES in engines.
    SET torques TO LIST().
    FOR engine IN engines { torques:ADD(V(0, 0, 0)). }
    SET unbalanced_torgue TO V(0,0,0).
    SET total_torque TO V(0,0,0).

    FOR i IN RANGE(engines:length) {
    SET pos TO engines[i]:position.
    SET engines[i]:thrustlimit TO 100.
    }

    FUNCTION dump {
        PRINT "Unbalanced torgue: " + unbalanced_torgue AT (0,0).
        PRINT "Balanced torgue: " + total_torque AT (0,1).
        FOR i IN RANGE(engines:length) {
            PRINT "Engine: " + i AT (0, i + 10).
            PRINT engines[i]:thrust + " " + engines[i]:maxthrust + " " + engines[i]:thrustlimit + "          " AT (20, i + 10).
        }
    }

    FUNCTION update_torques {
        SET unbalanced_torgue TO V(0,0,0).
        SET total_torque TO V(0,0,0).
        FOR i in RANGE(engines:length) {
            LOCAL thrust TO engines[i]:facing:forevector * engines[i]:maxthrust.
            SET torques[i] TO VCRS(thrust, engines[i]:position).
            SET unbalanced_torgue TO unbalanced_torgue + torques[i].
            SET total_torque TO total_torque + (torques[i] * (engines[i]:thrustlimit / 100)).
        }
    }

    FUNCTION simple_brent {
        parameter func.

        LOCAL y0 TO func:CALL(0).
        LOCAL y1 TO func:CALL(1).
        LOCAL y2 TO func:CALL(0.5).
        LOCAL a TO 2 * y0 + 2 * y1 - 4 * y2.
        LOCAL b TO 4 * y2 - y1 - 3 * y0.
        LOCAL c TO y0.

        if ABS(a) < 1e-6 {
            RETURN 1.
        }
        LOCAL x TO b / (-2 * a).

        IF x < 0 {
            RETURN 0.
        }
        IF x > 1 {
            RETURN 1.
        }
        RETURN x.
    }

    update_torques().
    dump().

    LOCAL config TO LIST().
    FOR engine IN ENGINES {
        config:ADD(engine:thrustlimit / 100).
    }

    for k in RANGE(10) {
        FOR i in RANGE(engines:length) {
            LOCAL slice TO {
                parameter x.

                LOCAL config_torgue TO V(0,0,0).
                FOR j in RANGE(engines:length) {
                    if j = i {
                        SET config_torgue TO config_torgue + (torques[j] * x).
                    } ELSE {
                        SET config_torgue TO config_torgue + (torques[j] * config[j]).
                    }
                }
                
                return config_torgue:SQRMAGNITUDE.
            }.
            SET config[i] TO simple_brent(slice@).
        }
    }

    FOR i in RANGE(engines:length) {
        SET engines[i]:thrustlimit TO config[i] * 100.
    }

    update_torques().
    dump().

    PRINT "Done".
}