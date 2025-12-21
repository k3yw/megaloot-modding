class_name CreditsPopup extends PopupContainer


var credits_dict = {
    "INSTINCT3": {
        "HandOfBlood": ["Maximilian Paul Karl-Heinz Knabe"], 
        "Product Manager Publishing": ["Melvin Frank"], 
        "Head of Business Development": ["Olga Voronina"], 
        "The whole Team HandOfBlood, especially": ["Carl Brose", "Denis Grasse", "Nik Peters", "Solveig Brockhaus"], 
    }, 

    "RAVENAGE GAMES": {
        "CMO": ["Anton Bond"], 
        "Publishing Producer": ["Imad Khalil"], 
        "Community Manager": ["Mehdi El-Assimi"], 
        "Product Lead Designer": ["Sergey Solodukhin"], 
        "Head of Business Development": ["Olga Voronina"], 
        "Community Director": ["Mike Pyslar"], 
        "Associate Publishing Producer": ["Anton Emelianov"], 
        "Marketing Managers": ["Ekaterina Nalgieva", "Polina Malahova"], 
        "Systems Administrator": ["Kirill Obukhov"], 
        "Business Development Manager": ["Ilya Revunov"], 
        "Designers": ["Mikhail Ermakov", "Elizaveta Karikh", "Dima Kalmykov", "July Baurova"], 
        "Financial Manager": ["Nana Gogoladze"], 
        "Producers": ["Mark Shumarov", "Viktor Reznikov"], 
        "Analyst": ["Vershinin Vladislav"], 
    }, 


    "": {
        "Music and Sounds": ["Guilherme Alexander"], 
        "Enemy and Item Art": ["Biohazard / Luca Tomas Caceres"], 
        "French Correction": ["Ralekk N.K."], 
        "": [], 
        "Playtesters":
            [
                "Wheelzy", 
                "Nihilty", 
                "Dix-Lan", 
                "MaverickAirsoft", 
                "Maross80", 
                "Niel \"Fiela\" Smit", 
                "Mircon", 
                "Jetnerd", 
                "Jefferson \"Jeffz\" Rodrigues", 
                "Zapallo", 
                "Pingas Khan", 
                "QuakeyJakey", 
                "ACturntUp", 
                "Zuki", 
                "Sword_kirby777", 
                "NSJ", 
                "ShadowHacker808", 
                "hofpants", 
                "Hoaq", 
                "Khanbad", 
                "Akiiro", 
                "Kaidak", 
                "YoJune", 
                "Track", 
                "Shenab Al-Rhajiim", 
                "As2piK", 
                "rchromatic", 
                "Asekelo", 
                "noribentou", 
                "BoxIsSleepy", 
                "SkifAlef", 
                "Arwen", 
                "Caborus", 
                "IdentityUnk", 
                "Loam", 
                "Aiedail", 
                "Truehearted (TSV)", 
                "omightymerlin", 
                "LtShinySides", 
                "Kailas", 
                "Igor Kabanov", 
                "Justin Carroll", 
                "otDan", 
                "Azoozy*", 
                "Hesanka", 
                "Nickypoo", 
                "Jesse G", 
                "Squirrelanna", 
                "Hesanka", 
                "ChaosGrimmon", 
            ]
    }

}


@export var playtesters_container: VBoxContainer
@export var credits_container: VBoxContainer
@export var confirm_button: GenericButton





func _ready() -> void :
    for main_group in credits_dict:
        var main_container = VBoxContainer.new()
        var sub_main_container = VBoxContainer.new()

        var main_label: GenericLabel = preload("res://scenes/ui/generic_label/generic_label.tscn").instantiate()
        main_container.add_child(main_label)

        main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        main_label.translate = false
        main_label.text = main_group

        credits_container.add_child(main_container)
        main_container.add_child(sub_main_container)

        main_container.add_theme_constant_override("separation", 25)
        sub_main_container.add_theme_constant_override("separation", 20)


        for sub_group in credits_dict[main_group]:
            var sub_container = VBoxContainer.new()
            sub_main_container.add_child(sub_container)

            if sub_group.length():
                var sub_label: GenericLabel = preload("res://scenes/ui/generic_label/generic_label.tscn").instantiate()
                sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                sub_container.add_child(sub_label)
                sub_label.translate = false
                sub_label.text = sub_group

            for person in credits_dict[main_group][sub_group]:
                var person_label: GenericLabel = preload("res://scenes/ui/generic_label/generic_label.tscn").instantiate()
                person_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                sub_container.add_child(person_label)
                person_label.translate = false
                person_label.text = person
                person_label.set_alpha(0.75)




func _process(delta: float) -> void :
    super._process(delta)

    if confirm_button.is_pressed:
        hide()
