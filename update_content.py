import copier


FROM_CONTENT = "D:/Steam/steamapps/common/dota 2 beta/content/dota_addons/attack_on_hero2/"
TO_CONTENT = "D:/Development/attack_on_hero2/content/"


if __name__ == '__main__':

    copier.Copier(FROM_CONTENT, TO_CONTENT).run()

    print("==> Content folder was updated.")
