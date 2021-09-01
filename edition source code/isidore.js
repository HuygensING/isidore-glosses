var cy = cytoscape({
    container: document.getElementById('cyto')
});

window.onhashchange = function(){ // handling back and forward buttons
//    console.log('window.onhashchange ', window.location.hash,globalThis.useraction,window.location.hash.substring(6));
    if (globalThis.useraction) {
        globalThis.useraction = false;
    } else {
        openhash();
    }
}

function openhash() {
    switch (true) {
        case (window.location.hash.startsWith('#left-')):
            openlefttab(window.location.hash.substring(6),'',false)
            break;
        case (window.location.hash.startsWith('#right-')):
            win = window.location.hash.substring(7);
            if (document.getElementById(win).style.display == "none"){
                openisitab(win,false);
            }
            break;
        case (window.location.hash.startsWith('#network-')):
            if (document.getElementById('network').style.display == "none"){
                openisitab('network',false)
            }
            win = window.location.hash.substring(9);
            if (globalThis.networktype != win) {
                setTimeout(function () {
                    creategraph(win,true,false)},250);
                }
            break;
        case (window.location.hash.startsWith('#msdesc-')):
            openlefttab('msdesc','',false);
            break;
        case (window.location.hash.startsWith('#msstats-')):
            openlefttab('msstats','',false);
            break;
        case (window.location.hash.startsWith('#glossms-')):
            openmsgloss(window.location.hash.substring(9), false)
            break;
        case (window.location.hash.startsWith('#gg_L')):
            t1 = window.location.hash.substring(5);
            t2 = t1.substring(0,t1.indexOf('.'));
            chap = romanize(parseInt(t2));
            openchapgloss(chap);
            break;
    }
}



window.onload = function () {
    currmss = JSON.parse(JSON.stringify(msslist));
    currclust = JSON.parse(JSON.stringify(clustlist));
    host = (window.location.hostname == 'peterboot.nl' ? 'isidore.sd.di.huc.knaw.nl' : window.location.hostname); 
    globalThis.curated = true;
    cy.on('mouseover', 'node', mouseovernode );
    cy.on('mouseout', 'node, edge', mouseout );
    cy.on('mouseover', 'edge', mouseoveredge);
    cy.on('mousedown', 'node', mousedownnode);
    cy.on('mousemove', 'node', mousemovenode);
    cy.on('mouseup', 'node', mouseupnode);
    globalThis.useraction = false;
    globalThis.backforward = false;
    globalThis.weight = 0;
    globalThis.tapped = '';
    globalThis.mousedown = false;
    openisitab('network',true);
    document.getElementById("actman").innerHTML  = currmss.length.toString() + ' of ' + msslist.length.toString()
    document.getElementById("actclust").innerHTML  = currclust.length.toString() + ' of ' + clustlist.length.toString()
    setTimeout(function () {func_ms_div(network_ms_div,cy,true)}, 250 );
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('ms')) {
        initms = urlParams.get('ms');
    } else {
        initms = 'VLO41';
    };
    if (urlParams.has('chap')) {
        initchap = urlParams.get('chap');
    } else {
        initchap = 'I';
    };
    if (urlParams.has('network')) {
        initchap = urlParams.get('network');
    } else {
        initnetwork= 'ms_div';
    };
    fetch('htmlfrag/glossI.html').then(function (response) {
        return response.text();
    }).then(function (html) {
        document.getElementById("glosses").innerHTML = html;
        glossonoff();
    }). catch (function (err) {
        console.warn('Something went wrong in loading chap 1 glosses.', err);
    });
    fetch('htmlfrag/glossms' + initms + '.html').then(function (response) {
        return response.text();
    }).then(function (html) {
        document.getElementById("manuscripts").innerHTML = html;
    }). catch (function (err) {
        console.warn('Something went wrong in loading ' + initms + ' glosses.', err);
    });
    if (urlParams.has('ms')) {
        globalThis.useraction = true;
        window.location.hash = 'glossms-' + initms;
        openisitab('manuscripts',true);
    }
};

/*                                                               FILTERING  */

function correctdisplayms () {
    for (i = 0; i < msslist.length; i++) {
        if (currmss.includes(msslist[i])) {
            document.getElementById('chk' + msslist[i]).checked = true;
        } else {
            document.getElementById('chk' + msslist[i]).checked = false
        }
    }
    if (currmss.length == 0) {
        document.getElementById('allmss3').indeterminate = false;
        document.getElementById('allmss3').checked = false;
    } else {
        if (currmss.length == msslist.length) {
            document.getElementById('allmss3').indeterminate = false;
            document.getElementById('allmss3').checked = true;
        } else {
            document.getElementById('allmss3').indeterminate = true;
            document.getElementById('allmss3').checked = false;
        }
    }
    glossonoff();
    document.getElementById("actman").innerHTML  = currmss.length.toString() + ' of ' + msslist.length.toString();
    correctmssgroup('msregion');
    correctmssgroup('mstype');
};

function correctmssgroup(group) {
    o = mssgroups[group]['values'];
    keys = Object.keys(o);
    for (i = 0; i < keys.length; i++) {
        ourelem = document.getElementById('chk-'+keys[i]);
        ourmss = mssgroups[group]['values'][keys[i]]['manuscripts']
        intersection = ourmss.filter(function(x) {
            return currmss.includes(x);
        });
        if (intersection.length == 0) {
            ourelem.indeterminate = false;
            ourelem.checked = false;
        } else {
            if (intersection.length == ourmss.length) {
                ourelem.indeterminate = false;
                ourelem.checked = true;
            } else {
                ourelem.indeterminate = true;
                ourelem.checked = false;
            }
        }
    }
};

function correctdisplayclust () {
    for (i = 0; i < clustlist.length; i++) {
        if (currclust.includes(clustlist[i])) {
            document.getElementById('clust' + clustlist[i]).checked = true;
        } else {
            document.getElementById('clust' + clustlist[i]).checked = false;
        }
    }
    if (currclust.length == 0) {
        document.getElementById('allclust3').indeterminate = false;
        document.getElementById('allclust3').checked = false;
    } else {
        if (currclust.length == clustlist.length) {
            document.getElementById('allclust3').indeterminate = false;
            document.getElementById('allclust3').checked = true;
        } else {
            document.getElementById('allclust3').indeterminate = true;
            document.getElementById('allclust3').checked = false;
        }
    }
    document.getElementById("actclust").innerHTML  = currclust.length.toString() + ' of ' + clustlist.length.toString();
};

function checkmsgroup(group,key) {
    ourmss = JSON.parse(JSON.stringify(mssgroups[group]['values'][key]['manuscripts']));
    if (document.getElementById('chk-' + key).checked == true) {
        for (i = 0; i < ourmss.length; i++) {
            if (! currmss.includes(ourmss[i])) {
                currmss.push(ourmss[i]);
            } 
        }
    } else {
        for (i = 0; i < ourmss.length; i++) {
            currmss= arrayRemove(currmss, ourmss[i]);
        }
    }
    correctdisplayms();
};

function addremoveclust(clust) {
    //console.log(clust)
    if (document.getElementById('clust' + clust).checked == true) {
        if (! currclust.includes(clust)) {
            currclust.push(clust);
        }
    } else {
        currclust = arrayRemove(currclust, clust);
    }
    correctdisplayclust()
}

function addremovems(ms) {
    if (document.getElementById('chk' + ms).checked == true) {
        if (! currmss.includes(ms)) {
            currmss.push(ms);
        }
    } else {
        currmss = arrayRemove(currmss, ms);
    }
    correctdisplayms()
}

function arrayRemove(arr, value) {
    return arr.filter(function (ele) {
        return ele != value;
    });
}

function checkallclust3() {
    if (document.getElementById('allclust3').checked) {
        currclust = JSON.parse(JSON.stringify(clustlist));
    } else {
        currclust = []
    }
    correctdisplayclust()
}

function checkallmss3() {
    if (document.getElementById('allmss3').checked) {
        currmss = JSON.parse(JSON.stringify(msslist));
    } else {
        currmss = []
    }
    correctdisplayms()
}

function funclustonoff(panel) {
    var unclusts = document.getElementsByClassName("unclustered");
    for (var i = 0; i < unclusts.length; i++) {
        if (document.getElementById('unclustonoff'+panel).checked) {
            unclusts[i].style.display = 'none';
        } else {
            unclusts[i].style.display = 'block';
        }
    }
    if (panel == 'm') {
        document.getElementById('unclustonoffc').checked = document.getElementById('unclustonoffm').checked
    } else {
        document.getElementById('unclustonoffm').checked = document.getElementById('unclustonoffc').checked
    }
}

function glossonoff() {
    var glosses = document.getElementsByClassName("gloss");
    if (msslist.length == currmss.length) {
        document.getElementById('nofilterwarning').style.display = 'block';
        document.getElementById('filterwarning').style.display = 'none';
        for (var i = 0; i < glosses.length; i++) {
            glosses[i].style.display = 'block';
        }
    } else {
        document.getElementById('nofilterwarning').style.display = 'none';
        document.getElementById('filterwarning').style.display = 'block';
        for (var i = 0; i < glosses.length; i++) {
            glosses[i].style.display = 'none';
        }
        if (currmss.length > 0) {
            for (var j = 0; j < currmss.length; j++) {
                var glossesms = document.getElementsByClassName(currmss[j]);
                for (var i = 0; i < glossesms.length; i++) {
                    glossesms[i].style.display = 'block';
                }
            }
            /*             for (var i = 0; i < glosses.length; i++) {
            var intersection = currmss.filter(function(x) {glosses[i].classList.contains(x)});
            if (intersection.length > 0) {
            glosses[i].style.display = 'display';
            } else {
            glosses[i].style.display = 'none';
            }
            } */
        }
    }
}



/*                                                               TAB HANDLING */

function openisitab(isitabName,sethash) {
    var i, x, tablinks;
    x = document.getElementsByClassName("isitab");
    for (i = 0; i < x.length; i++) {
        x[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablink");
    for (i = 0; i < x.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" w3-red", "");
    }
    document.getElementById(isitabName).style.display = "block";
    //evt.currentTarget.className += " w3-red";
    document.getElementById(isitabName + 'b').className += " w3-red";
    if (sethash) {
        globalThis.useraction = true;
        window.location.hash = 'right-'+ isitabName;
    }
}

function openlefttab(lefttabName, hash, sethash) {
    var i, x, tablinks;
//    console.log(hash,hash!=null);
    x = tablinks = document.getElementsByClassName("lefttab");
    for (i = 0; i < x.length; i++) {
        tablinks[i].style.display = "none";;
    }
    if (['home','intro','msdesc','msstats','networks','clusters','sources','biblio'].includes(lefttabName)) {
        document.getElementById(lefttabName).style.display = "block";
    } else {
        fetch('htmlfrag/text' + lefttabName + '.html').then(function (response) {
            return response.text();
        }).then(function (html) {
            document.getElementById("text").innerHTML = html;
        }). catch (function (err) {
            console.warn('Something went wrong.', err);
        });
        document.getElementById('text').style.display = "block";
        fetch('htmlfrag/gloss' + lefttabName + '.html').then(function (response) {
            return response.text();
        }).then(function (html) {
            document.getElementById("glosses").innerHTML = html;
            glossonoff();
        }). catch (function (err) {
            console.warn('Something went wrong.', err);
        });
        document.getElementById('text').style.display = "block";
        openisitab('glosses',false)
    }
    if (sethash) {
        globalThis.useraction = true;
        if (hash=='') {
            window.location.hash = 'left-'+ lefttabName;
        } else {
            window.location.hash = hash;
        }
    }
    x = tablinks = document.getElementsByClassName("lefttablink");
    for (i = 0; i < x.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" w3-red", "");
    }
    document.getElementById('tab' + lefttabName).className += " w3-red";
}

function openmsgloss(msid,sethash) {
        fetch('htmlfrag/glossms' + msid + '.html').then(function (response) {
            return response.text();
        }).then(function (html) {
            document.getElementById("manuscripts").innerHTML = html;
        }). catch (function (err) {
            console.warn('Something went wrong in loading ms glosses ' + msid, err);
        });
        openisitab('manuscripts',sethash)
}

function openchapgloss(chap){
    if (document.getElementById('gloss'+chap) == null){
        fetch('htmlfrag/gloss' + chap + '.html').then(function (response) {
            return response.text();
        }).then(function (html) {
            document.getElementById("glosses").innerHTML = html;
            glossonoff();
        }). catch (function (err) {
            console.warn('Something went wrong.', err);
        });
    }
    if (document.getElementById('glosses').style.display != "block") {
        openisitab('glosses',true)
    }
}

function openmsglosshash(ms) {
    globalThis.useraction = true;
    window.location.hash = 'glossms-' + ms;
    openmsgloss(ms)
}


/*                                                                                   slider stuff                   */

var slider = document.getElementById("weightRange");
var output = document.getElementById("weightRangeVal");
output.innerHTML = slider.value; // Display the default slider value

// Update the current slider value (each time you drag the slider handle)
slider.oninput = function() {
  output.innerHTML = this.value;
  globalThis.weight = this.value;
  redisplayNetwork();
}

/*                                                                                   various                  */

function dummy () {
    return 0
}

function romanize (num) {
    if (isNaN(num))
        return NaN;
    var digits = String(+num).split(""),
        key = ["","C","CC","CCC","CD","D","DC","DCC","DCCC","CM",
               "","X","XX","XXX","XL","L","LX","LXX","LXXX","XC",
               "","I","II","III","IV","V","VI","VII","VIII","IX"],
        roman = "",
        i = 3;
    while (i--)
        roman = (key[+digits.pop() + (i * 10)] || "") + roman;
    return Array(+digits.join("") + 1).join("M") + roman;
}
