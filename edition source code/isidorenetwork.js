/*                                                               NETWORK DISPLAY */

var dummyDomEle = document.createElement('div');

var contMenu = {
    menuItems:[ {
        id: 'remove',
        content: 'remove',
        tooltipText: 'remove',
        image: {
            src: "pics/remove.svg", width: 12, height: 12, x: 6, y: 4
        },
        selector: 'node, edge',
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            removed = target.remove();
            
            globalThis.contextMenu.showMenuItem('undo-last-remove');
        },
        hasTrailingDivider: true
    }, {
        id: 'undo-last-remove',
        content: 'undo last remove',
        selector: 'node, edge',
        show: false,
        coreAsWell: false,
        onClickFunction: function (event) {
            if (removed) {
                removed.restore();
            }
            globalThis.contextMenu.hideMenuItem('undo-last-remove');
        },
        hasTrailingDivider: true
    }, {
        id: 'preview-chapter',
        content: 'preview chapter',
        selector: 'node[type="div"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            fetch('htmlfrag/text' + target.data('id') + '.html').then(function (response) {
                return response.text();
            }).then(function (html) {
                document.getElementById("modalcontent").innerHTML = html;
                document.getElementById('modal-01').style.display = 'block';
            }). catch (function (err) {
                console.warn('Something went wrong.', err);
            });
        },
        hasTrailingDivider: true
    }, {
        id: 'view-chapter',
        content: 'view chapter',
        selector: 'node[type="div"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            globalThis.useraction = true;
            window.location.hash = 'left-' + target.data('id');
            openlefttab(target.data('id'))
        },
        hasTrailingDivider: true
    }, {
        id: 'go-db',
        content: 'show in database (new tab)',
        selector: 'node[type="ms"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            window.open('https://' + host + '/#detail/' + target.data('ikid'), 'msdb');
        },
        hasTrailingDivider: true
    }, {
        id: 'preview-msgloss',
        content: 'preview ms glosses',
        selector: 'node[type="ms"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            fetch('htmlfrag/glossms' + target.data('id') + '.html').then(function (response) {
                return response.text();
            }).then(function (html) {
                document.getElementById("modalcontent").innerHTML = html;
                document.getElementById('modal-01').style.display = 'block';
            }). catch (function (err) {
                console.warn('Something went wrong in previewing ms glosses.', err);
            });
        },
        hasTrailingDivider: true
    }, {
        id: 'view-msgloss',
        content: 'view ms glosses',
        selector: 'node[type="ms"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            openmsglosshash(target.data('id'));
        },
        hasTrailingDivider: true
    }, {
        id: 'view-msdesc',
        content: 'view ms desc',
        selector: 'node[type="ms"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            openlefttab('msdesc', 'msdesc-' + target.data('id'))
        },
        hasTrailingDivider: true
    }, {
        id: 'view-msstats',
        content: 'view ms stats',
        selector: 'node[type="ms"]',
        show: true,
        coreAsWell: false,
        onClickFunction: function (event) {
            var target = event.target || event.cyTarget;
            openlefttab('msstats', 'msstats-' + target.data('id'))
        },
        hasTrailingDivider: true
    }
    ]
};

globalThis.contextMenu = cy.contextMenus(contMenu);

function mousedownnode (evt) {
    var node = evt.target;
    globalThis.mousedown = true;
    if (node.id() == globalThis.tapped) {
        globalThis.tapped = '';
        redisplayNetwork()
    } else {
        globalThis.tapped = node.id();
        cy.elements().addClass('invis');
        node.removeClass('invis');
        cy.filter("node[type='div']").removeClass('invis');
        node.connectedEdges().forEach( function (ele) {
            ele.removeClass('invis');   
            ele.source().removeClass('invis');
            ele.target().removeClass('invis');
        });
    }
}

function mousemovenode (evt) {
    var node = evt.target;
    if (globalThis.mousedown & globalThis.tapped != '') {
        globalThis.tapped = '';
        redisplayNetwork()
    }
}

function mouseupnode (evt) {
    var node = evt.target;
    globalThis.mousedown = false;
}

function mouseovernode (evt) {
    var node = evt.target;
    var ref = node.popperRef();
    globalThis.tip = new tippy(dummyDomEle, {
        // tippy props:
        getReferenceClientRect: ref.getBoundingClientRect, // https://atomiks.github.io/tippyjs/v6/all-props/#getreferenceclientrect
        trigger: 'manual', // mandatory, we cause the tippy to show programmatically.
        content: function () {
            var content = document.createElement('div');
            t = inpar('node type: ' + node.data('type')) + inpar('id: ' + node.data('id')) + inpar('degree: ' + node.degree());
            switch (node.data('type')) {
                case 'ms':
                    if (globalThis.networktype == 'ms_div') {
                        t = t + inpar('summed edge weight: ' + nodesummedweight(node));
                    }
                    break;
                case 'clus': 
                    t = t + inpar('description: ' + node.data('desc'));
                    break;
                case 'div': 
                        t = t + inpar('head: ' + node.data('head'));
                    break;
            }
            content.innerHTML = t;
            return content;
        }
    });
    tip.show();
}

function mouseoveredge (evt) {
    var node = evt.target;
    var ref = node.popperRef();
    globalThis.tip = new tippy(dummyDomEle, {
        // tippy props:
        getReferenceClientRect: ref.getBoundingClientRect, // https://atomiks.github.io/tippyjs/v6/all-props/#getreferenceclientrect
        trigger: 'manual', // mandatory, we cause the tippy to show programmatically.
        followCursor: true,
        content: function () {
            var content = document.createElement('div');
            t = inpar('weight: ' + edgeweight(node)) + inpar('from ' + node.data('type').split('_')[0] + ' ' + node.data('source') + ' to ' + node.data('type').split('_')[1] + ' ' + node.data('target')) ;
            if (node.data('type') == 'ms_ms') {
                t = t + inpar('cluster: ' + node.data('clus'));
            }
            content.innerHTML = t;
            return content;
        }
    });
    tip.show();
}

function mouseout (evt) {
    var node = evt.target;
    globalThis.tip.destroy();
}

function inpar(str) {
    return '<p>' + str + '</p>'
}

function savegraph(choice) {
    var a = document.createElement('a');
    if (choice == 'png') {
        var png64 = cy.png();
        a.href = png64;
        a.download = "network.png";
    } else {
        var txt = cy.json();
        var json = JSON.stringify(txt);
        var blob = new Blob([json], {
            type: "application/json"
        });
        var url = URL.createObjectURL(blob);
        a.href = url;
        a.download = 'network.json';
    }
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
};

function redisplayNetwork() {   
    cy.elements().addClass('invis');
    switch (globalThis.networktype) {
        case 'ms_div':
            cy.filter("node[type='div']").removeClass('invis');
            cy.filter("node[type='ms']").forEach( function (ele) {
                thisweight = nodesummedweight(ele);
                if (document.getElementById("w1").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight1'))};
                if (document.getElementById("w2").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight2'))};
                if (document.getElementById("w3").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight3'))};
                if (document.getElementById("w4").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight4'))};
                if (thisweight >= globalThis.weight) {
                    ele.removeClass('invis');
                    ele.connectedEdges().forEach( function (ele) {
                        ele.removeClass('invis');
                    });
                };
            }); 
            break;
        case 'ms_clus':
            cy.filter("edge").forEach( function (ele) {
                thisweight = edgeweight(ele);
                if (thisweight >= globalThis.weight) {
                    ele.removeClass('invis');
                    ele.source().removeClass('invis');
                    ele.target().removeClass('invis');
                };
            }); 
            break;
        case 'ms_ms':
            cy.filter("edge").forEach( function (ele) {
                thisweight = edgeweight(ele);
                if (thisweight >= globalThis.weight) {
                    ele.removeClass('invis');
                    ele.source().removeClass('invis');
                    ele.target().removeClass('invis');
                };
            }); 
            break;
        default: 
            console.log('Invalid network type: ' + globalThis.networktype);
    }
}

function creategraph(curated){
    switch(globalThis.networktype) {
        case 'ms_div':
            func_ms_div(network_ms_div,cy,curated)
            break;
        case 'ms_clus':
            func_ms_clus(network_ms_clus,cy,curated)
            break;
        default:
            func_ms(network_ms,cy,curated)
            break;
    }
}

function edgeweight(ele) {
    thisweight = 0;
    if (document.getElementById("w1").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('weight1'))};
    if (document.getElementById("w2").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('weight2'))};
    if (document.getElementById("w3").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('weight3'))};
    if (document.getElementById("w4").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('weight4'))};
    return thisweight;
}

function nodesummedweight(ele) {
    thisweight = 0;
    if (document.getElementById("w1").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight1'))};
    if (document.getElementById("w2").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight2'))};
    if (document.getElementById("w3").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight3'))};
    if (document.getElementById("w4").checked | globalThis.curated) {thisweight = thisweight + Number(ele.data('summedweight4'))};
    return thisweight;
}

function func_ms_div(network, cy, curated) {
    globalThis.networktype = 'ms_div';
    cy.remove(cy.elements())
    cy.add(network);
    if (curated) {
        usemss = JSON.parse(JSON.stringify(msslist));
        globalThis.curated = true;
    } else {
        usemss = JSON.parse(JSON.stringify(currmss));
        globalThis.curated = false;
    }
    cy.remove(cy.elements(function (ele) {
        return ele.isNode() & ! usemss.includes(ele.data('id')) & ele.data('type') == 'ms'
    }));
    cy.remove(cy.elements(function (ele) {
        return ele.isEdge() & ! ((document.getElementById("w1").checked & Number(ele.data('weight1')) > 0) | 
                                (document.getElementById("w2").checked & Number(ele.data('weight2')) > 0) |  
                                (document.getElementById("w3").checked & Number(ele.data('weight3')) > 0) |  
                                (document.getElementById("w4").checked & Number(ele.data('weight4')) > 0)  
                                )
    }));
    cy.remove(cy.elements('node[[degree = 0]][type = "ms"]'));
    var div = cy.filter("node[type='div']");
    var pos =[];
    for (i = 0; i < div.length; i++) {
        pos.push({
            nodeId: div[i].data('id'), position: {
                x: 500, y: 20 + 60 * div[i].data('pos')
            }
        })
    }
    document.getElementById('actclustcontrol').style.display = 'none';
    document.getElementById('actweightcontrol').style.display = 'table-row';
    var ms = cy.filter("node[type='ms']");
    var maxweight = 0;
    for (i = 0; i < ms.length; i++) {
        thisweight = nodesummedweight(ms[i]);
        if (thisweight > maxweight) { maxweight = thisweight };
        if (thisweight == 0) {
            cy.remove(ms[i]);
        }
    }
    md = ms.maxDegree();
    var rpc =[];
    for (i = 0; i < ms.length; i++) {
        rpc.push({
            left: div[5].data('id'), right: ms[i].data('id'), gap: (ms[i].degree() / md) * 1600
        })
    }
    document.getElementById("weightRange").max = maxweight;
    weightrangezero();
    document.getElementById("uppboundval").textContent = maxweight.toString(); 
    cy.style ([// the stylesheet for the graph
    {
        selector: 'node[type="ms"]',
        style: {
            'background-color': 'red',
            //'background-color': function( ele ){ if (ele.data('type') == 'ms') { return 'red'} else { return 'blue'} },
            'label': 'data(id)',
            'font-size': 30
        }
    }, {
        selector: 'node[type="div"]',
        style: {
            'background-color': 'green',
            //'background-color': function( ele ){ if (ele.data('type') == 'ms') { return 'red'} else { return 'blue'} },
            'label': 'data(id)',
            'font-size': 30
        }
    }, {
        selector: '.invis',
        style: {
            visibility : 'hidden'
        }
    }, {
        selector: 'edge',
        style: {
            'width': function (ele) {
                return Math.sqrt(edgeweight(ele))
            },
            'line-color': '#ccc',
            'target-arrow-color': '#ccc',
            // 'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
        }
    }]);
    var selectedLayout = getselectedlayout();
    var layout = ( (selectedLayout > '') & !curated ? 
        cy.layout({name: selectedLayout}) :
        cy.layout({name: 'fcose', fixedNodeConstraint: pos, relativePlacementConstraint: rpc, nodeRepulsion: 500000}) );
    layout.run();
};

function func_ms_clus(network, cy, curated) {
    globalThis.networktype = 'ms_clus';
    cy.remove(cy.elements())
    cy.add(network);
    if (curated) {
        usemss = JSON.parse(JSON.stringify(msslist));
        useclust = JSON.parse(JSON.stringify(clustlist));
        globalThis.curated = true;
    } else {
        usemss = JSON.parse(JSON.stringify(currmss));
        useclust = JSON.parse(JSON.stringify(currclust));
        globalThis.curated = false;
    }
    cc = arrayRemove(useclust, 'c_X1')
    cc = arrayRemove(cc, 'c_X2')
    cy.remove(cy.elements(function (ele) {
        return ele.isNode() & ! usemss.concat(cc).includes(ele.data('id'))
    }));
    document.getElementById('actclustcontrol').style.display = 'table-row';
    document.getElementById('actweightcontrol').style.display = 'table-row';
    var edges = cy.filter("edge");
    var maxweight = 0;
    for (i = 0; i < edges.length; i++) {
        thisweight = edgeweight(edges[i]);
        if (thisweight > maxweight) { maxweight = thisweight };
        if (thisweight == 0) {
            cy.remove(edges[i]);
        }
    }
    cy.remove(cy.elements('node[[degree = 0]]'));
    document.getElementById("weightRange").max = maxweight; 
    document.getElementById("uppboundval").textContent = maxweight.toString(); 
    weightrangezero();
    cy.style ([// the stylesheet for the graph
    {
        selector: 'node',
        style: {
            //'background-color': 'red',
            'background-color': function (ele) {
                if (ele.data('type') == 'ms') {
                    return 'red'
                } else {
                    return ele.data('color')
                }
            },
            'label': 'data(id)',
            'font-size': 12
        }
    }, {
        selector: 'node[type="clus"]',
        style: {
            shape : 'rectangle'
        }
    }, {
        selector: '.invis',
        style: {
            visibility : 'hidden'
        }
    }, {
        selector: 'edge',
        style: {
            'width': function (ele) {
                return Math.sqrt(edgeweight(ele))
            },
            //'width': 30,
            'line-color': '#ccc',
            'target-arrow-color': '#ccc',
            // 'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
        }
    }]);
    var selectedLayout = getselectedlayout();
    var layout = ( (selectedLayout > '') & !curated ? 
        cy.layout({name: selectedLayout}) :
        cy.layout({name: 'cose', 'circle': true }));
    layout.run();
}

function func_ms(network, cy, curated) {
     globalThis.networktype = 'ms_ms';
    
    var w = cy.width();
    var h = cy.height();
    var s = Math.min(w, h);
    
    cy.remove(cy.elements())
    cy.add(network);
    if (curated) {
        usemss = JSON.parse(JSON.stringify(msslist));
        useclust = JSON.parse(JSON.stringify(clustlist));
        globalThis.curated = true;
    } else {
        usemss = JSON.parse(JSON.stringify(currmss));
        useclust = JSON.parse(JSON.stringify(currclust));
        globalThis.curated = false;
    }
    cy.remove(cy.elements(function (ele) {
        return ele.isNode() & ! usemss.includes(ele.data('id'))
    }));
    cc = arrayRemove(useclust, 'c_X1')
    cc = arrayRemove(cc, 'c_X2')
    cy.remove(cy.elements(function (ele) {
        return ele.isEdge() & ! cc.includes(ele.data('clus'))
    }));
    document.getElementById('actclustcontrol').style.display = 'table-row';
    document.getElementById('actweightcontrol').style.display = 'table-row';
    var edges = cy.filter("edge");
    var maxweight = 0;
    for (i = 0; i < edges.length; i++) {
        thisweight = edgeweight(edges[i]);
        if (thisweight > maxweight) { maxweight = thisweight };
        if (thisweight == 0) {
            cy.remove(edges[i]);
        }
    }
    cy.remove(cy.elements('node[[degree = 0]]'));
    document.getElementById("weightRange").max = maxweight; 
    weightrangezero();
    document.getElementById("uppboundval").textContent = maxweight.toString(); 
    cy.style ([// the stylesheet for the graph
    {
        selector: 'node',
        style: {
            //'background-color': 'red',
            'background-color': function (ele) {
                if (ele.data('type') == 'ms') {
                    return 'black'
                } else {
                    return ele.data('color')
                }
            },
            'label': 'data(id)',
            'height': function (ele) {
                return 5 + (ele.degree() * .35)
            },
            'width': function (ele) {
                return 5 + (ele.degree() * .35)
            },
            'font-size': 12
        }
    }, {
        selector: '.invis',
        style: {
            visibility : 'hidden'
        }
    }, {
        selector: 'edge',
        style: {
            'width': function (ele) {
                return Math.sqrt(edgeweight(ele)) * .6
            },
            'line-color': function (ele) {
                return ele.data('color')
            },
            'target-arrow-color': '#ccc',
            // 'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'opacity': .5
        }
    }]);
    // demo your core ext
    var contextMenu = cy.contextMenus(contMenu);
    var selectedLayout = getselectedlayout();
    var layout = ( (selectedLayout > '') & !curated ? 
        cy.layout({name: selectedLayout}) :
        cy.layout({name: 'preset',positions: function (ele) {return {x: (ele.data('mslong') * s) + rand(), y: (ele.data('mslat') * s) + rand()}}}));
    layout.run();
}

function getselectedlayout(){
    var form = document.getElementById('layoutbuttons');
    var form_elements = form.elements;
    var selectedLayout = form_elements['layout'].value;
    return selectedLayout;
}

function weightrangezero(){
    globalThis.weight = 0;
    output.innerHTML = 0;
    document.getElementById("weightRange").value = 0;
}

function rand() {
    return (Math.random() - .5) * 50
}