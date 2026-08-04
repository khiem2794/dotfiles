pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    readonly property string sans: interFont.name || "Inter Variable"
    readonly property string mono: firaCodeFont.name || "Fira Code"
    readonly property string icons: materialSymbolsFont.name || "Material Symbols Rounded"
    readonly property string nerd: firaCodeFont.name || "FiraCode Nerd Font"

    FontLoader {
        id: interFont
        source: Qt.resolvedUrl("../assets/fonts/inter/InterVariable.ttf")
    }

    FontLoader {
        id: firaCodeFont
        source: Qt.resolvedUrl("../assets/fonts/nerd-fonts/FiraCodeNerdFont-Regular.ttf")
    }

    FontLoader {
        id: materialSymbolsFont
        source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }
}
