let lac, darken, hideChildren, hide
let tf, actTab, hideDisabledClasses, keyl
lac = (dis, hideText) => {
    if (!dis) return
    dis.setAttribute?.("style", `background-color:#000!important; ${hideText ? 'color:#000!important' : 'color:#d3beff!important'}`)
    // console.log(dis.childNodes)
    // if (dis.childNodes)
    //     for (let w = 0; w < dis.childNodes.length; w++) {
    //         dis.childNodes[w]?.setAttribute?.("style", `background-color:#000!important; ${hideText ? 'color:#000!important' : 'color:#d3beff!important'}`)
    //     }
}

darken = (func, tins, no_text = []) => {
    for (let i = 0; i < tins.length; i++) {
        let tar = document[func]?.(tins[i])
        if (tar?.length)
            for (let n = 0; n < tar.length; n++) {
                lac(tar[n], no_text.find(f => f == tins[i]))
            }
        else
            lac(tar)
    }
}

hideChildren = (func, tins) => {
    for (let i = 0; i < tins.length; i++) {
        let tar = document[func]?.(tins[i])
        if (tar?.length)
            for (let l = 0; l < tar.length; l++) {
                for (let n = 0; n < tar[l].childNodes.length; n++) {
                    tar[l].childNodes[0]?.setAttribute("style", "display:none")
                }
            }
        else {
            if (tar.childNodes?.length) {
                for (let n = 0; n < tar.childNodes.length; n++) {
                    tar.childNodes[0]?.setAttribute("style", "display:none")
                }
            }
        }
    }
}
hide = (func, tins) => {
    for (let i = 0; i < tins.length; i++) {
        let tar = document[func]?.(tins[i])
        if (tar?.length)
            for (let n = 0; n < tar.length; n++) {
                tar[n].setAttribute?.("style", "display:none")
            }
        else
            tar?.setAttribute?.("style", "display:none")
    }
}

// darken("getElementsByTagName", ["html", "body", "nav", "tabs", "tab", "main", "pre", "app", "p", "h1", "h2", "h3", "span", "a"])
// darken(document.getElementById, ["search-input"])

darken("getElementsByTagName", ["html", "body", "nav", "tabs", "tab", "main", "pre", "app", "p", "h1", "h2", "h3", "span", "a"])
darken("getElementsByClassName", ["nav", "tabs", "tab", "main", "desktop-navbar"], ["tab"])

tf = document.getElementsByClassName('tabs flex')
for (let i = 0; i < tf.length; i++) {
    tf[i].setAttribute("style", "margin-top:200px; background-color:#000")
}
hideChildren("getElementsByClassName", ['logo', 'tab'])
hide("getElementsByClassName", ["download-section", "modify-container", "left", "m-b footer", "notification", "m-t-l", "caret", "tab small"])

actTab = document.getElementsByClassName("tab active")
for (let i = 0; i < actTab.length; i++) {
    actTab[i].childNodes[0]?.setAttribute("style", "color:#70a")
}
// document.getElementById("html").setAttribute("style", "scrollbar-width: none")
// keyl = document.getElementsByClassName("labels")
// for (let i = 0; i < keyl.length; i++) {
//     keyl[i].childNodes?.[0]?.setAttribute("style", "scale:1.1")
// }
// hideDisabledClasses = ["content transparent"]
// for (let i = 0; i < hideDisabledClasses.length; i++) {
//     let tar = document.getElementsByClassName(hideDisabledClasses[i])
//     if (tar?.length) {
//         for (let l = 0; l < tar.length; l++) {
//             tar[l]?.setAttribute("style", "opacity:.91; background-color:#000!important; color:#000!important")
//         }
//     }
// }
