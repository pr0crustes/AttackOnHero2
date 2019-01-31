del "D:\Development\attack_on_hero2\game\*.*" /s /f /q
FOR /D %%p IN ("D:\Development\attack_on_hero2\game\*.*") DO rmdir "%%p" /s /q

del "D:\Development\attack_on_hero2\content\*.*" /s /f /q
FOR /D %%p IN ("D:\Development\attack_on_hero2\content\*.*") DO rmdir "%%p" /s /q

xcopy "D:\Steam\steamapps\common\dota 2 beta\game\dota_addons\attack_on_hero_two" "D:\Development\attack_on_hero2\game" /E /Y
xcopy "D:\Steam\steamapps\common\dota 2 beta\content\dota_addons\attack_on_hero_two" "D:\Development\attack_on_hero2\content" /E /Y
