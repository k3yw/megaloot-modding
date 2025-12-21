class_name Format

enum Rules{USE_PREFIX, USE_SUFFIX, PERCENTAGE, IGNORE_PLUS, IS_WHOLE}




static func number(amount: float, rules: Array[Rules] = []) -> String:
    var num: String = str(amount)
    var prefix: String = ""
    var suffix: String = ""


    if amount < 1000:
        if amount >= 100:
            num = str(floori(amount))
        else:
            num = str(floorf(amount * 10.0) / 10.0)
            if rules.has(Rules.IS_WHOLE):
                num = str(roundi(amount))


    num = num.trim_suffix(".0")

    if num.begins_with("-"):
        num = num.trim_prefix("-")
        prefix = "-"

    if rules.has(Rules.USE_PREFIX):
        if not rules.has(Rules.IGNORE_PLUS):
            if amount > 0.0:
                prefix = "+"


    if amount >= 1000.0:
        if rules.has(Rules.USE_SUFFIX):
            if amount >= 1000.0:
                num = str(amount / 1000.0)
                suffix = "K"

            if amount >= 1000000.0:
                num = str(amount / 1000000.0)
                suffix = "M"

            if amount >= 1000000000.0:
                num = str(amount / 1000000000.0)
                suffix = "B"

            if amount >= 1000000000000.0:
                num = str(amount / 1000000000000.0)
                suffix = "T"

            if amount >= 1e+15:
                num = str(amount / 1e+15)
                suffix = "Q"

            if amount >= 1e+18:
                num = str(amount / 1e+18)
                suffix = "S"

            if amount >= 1e+21:
                num = str(amount / 1e+21)
                suffix = "O"

            if amount >= 1e+24:
                num = str(amount / 1e+24)
                suffix = "N"

            if amount >= 1e+27:
                num = str(amount / 1e+27)
                suffix = "D"

            if amount >= 1e+30:
                num = str(amount / 1e+30)
                suffix = "U"

            if amount >= 1e+33:
                num = str(amount / 1e+33)
                suffix = "V"

            if amount >= 1e+36:
                num = str(amount / 1e+36)
                suffix = "G"

            if amount >= 1e+39:
                num = str(amount / 1e+39)
                suffix = "R"

            if amount >= 1e+42:
                num = str(amount / 1e+42)
                suffix = "E"

            if amount >= 1e+45:
                num = str(amount / 1e+45)
                suffix = "F"

            if amount >= 1e+48:
                num = str(amount / 1e+48)
                suffix = "H"

            if amount >= 1e+51:
                num = str(amount / 1e+51)
                suffix = "I"

            if amount >= 1e+54:
                num = str(amount / 1e+54)
                suffix = "J"

            if amount >= 1e+57:
                num = str(amount / 1e+57)
                suffix = "L"

            if amount >= 1e+60:
                num = str(amount / 1e+60)
                suffix = "P"

            if amount >= 1e+63:
                num = str(amount / 1e+63)
                suffix = "W"

            if amount >= 1e+63:
                num = str(amount / 1e+63)
                suffix = "X"

            if amount >= 1.0000000000000001e+66:
                num = str(amount / 1.0000000000000001e+66)
                suffix = "Y"

            if amount >= 1e+69:
                num = str(amount / 1e+69)
                suffix = "Z"


            if "." in num:
                num = num.left(4)
                while num.ends_with("0"):
                    num = num.trim_suffix("0")
                num = num.trim_suffix(".")

            if not "." in num:
                num = num.left(3)


        if not rules.has(Rules.USE_SUFFIX):
            var i: int = num.length() - 3
            while i > 0:
                num = num.insert(i, ",")
                i = i - 3

            num = num.trim_prefix(",")




    if rules.has(Rules.PERCENTAGE):
        return prefix + num + suffix + "%"


    return prefix + num + suffix



static func time(time_delta: float) -> String:
    var hours: int = int(time_delta / 3600)
    var minutes: int = int(float(int(time_delta) % 3600) / 60)
    var seconds = int(time_delta) % 60
    var milliseconds = int((time_delta - int(time_delta)) * 1000)

    if hours == 0:
        return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

    return "%02d:%02d:%02d.%03d" % [hours, minutes, seconds, milliseconds]



static func to_seconds(sec: int) -> String:
    var hours: int = int(float(sec) / 3600)
    var minutes: int = int(float(sec % 3600) / 60)
    var secs: int = sec % 60

    if hours > 0:
        return "%dh %02dm %02ds" % [hours, minutes, secs]

    return "%dm %02ds" % [minutes, secs]
