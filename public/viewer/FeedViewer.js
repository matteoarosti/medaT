// ----------------------------------------
function acs_show_panel_std(app, url, jsonData, tab_id, listeners, loadBodyMask){
	
	if(typeof(listeners)==='undefined' || listeners==null) listeners = {};		
	
	if (loadBodyMask == 'Y')
		Ext.getBody().mask('Loading... ', 'loading').show();	
	

	mp = app.feedInfo;
	mp_tab = Ext.getCmp(tab_id);

	if (mp_tab){
		mp_tab.show();		    	
	} else {	
		//carico la form dal json ricevuto da php
		Ext.Ajax.request({
		        url        : url,
		        method     : 'POST',
		        waitMsg    : 'Data loading',
		        jsonData: jsonData,	        
		        success : function(result, request){
		            var jsonData = Ext.decode(result.responseText);
		            mp.add(jsonData.items);		            
		            mp.doLayout();
		            mp.show();
					//mostro l'ultimo tab aggiunto
		            mp.setActiveTab(mp.items.length - 1);
		        },
		        failure    : function(result, request){
		            Ext.Msg.alert('Message', 'No data to be loaded');
		        }
		    });
	}	
}



function acs_show_win_std(titolo, url, jsonData, width, height, listeners, iconCls, maximize, loadBodyMask, open_vars, help_codice){
	
	if(typeof(width)==='undefined'  || width==null)  width  = 600;
	if(typeof(height)==='undefined' || height==null) height = 400;
	if(typeof(listeners)==='undefined' || listeners==null) listeners = {};	
	if(typeof(iconCls)==='undefined'  || iconCls==null) iconCls = 'iconSpedizione';	
	
	if (loadBodyMask == 'Y')
		Ext.getBody().mask('Loading... ', 'loading').show();	
	

	if (!typeof(help_codice) === 'undefined'){
			tools = [
				{
				    type:'help',
				    tooltip: 'Help',
				    handler: function(event, toolEl, panel){
				        show_win_help('MAIN_SEARCH');
				    }
				}								
			]
	} else tools = [];
	
	print_w = new Ext.Window({
		  width: width
		, height: height
		, plain: true
		, title: titolo
		, layout: 'fit'
		, border: true
		, closable: true
		, listeners: listeners
    	, iconCls: iconCls
    	, maximizable: true
    	, open_vars: open_vars
    	, tools: tools
	});	
	
	if (maximize == 'Y')
		print_w.show().maximize();
	else
		print_w.show();

	//carico la form dal json ricevuto da php
	Ext.Ajax.request({
	        url        : url,
	        method     : 'POST',
	        waitMsg    : 'Data loading',
	        jsonData: jsonData,	        
	        success : function(result, request){
	            var jsonData = Ext.decode(result.responseText);
	            print_w.add(jsonData.items);
	            print_w.doLayout();
	        },
	        failure    : function(result, request){
	            Ext.Msg.alert('Message', 'No data to be loaded');
	        }
	    });	
	    
  return print_w;	    
}






// ----------------------------------------



/**
 * @class FeedViewer.FeedViewer
 * @extends Ext.container.Viewport
 *
 * The main FeedViewer application
 * 
 * @constructor
 * Create a new Feed Viewer app
 * @param {Object} config The config object
 */


Ext.define('FeedViewer.App', {
	requires : [ 'Ext.container.Viewport', 'FeedViewer.MovimentoPanel', 'FeedViewer.ScGrid', 'FeedViewer.MenuPanel', 'FeedViewer.NewHandlingHeaderPanel'],
    extend: 'Ext.container.Viewport',
    
    initComponent: function(){
        Ext.define('Feed', {
            extend: 'Ext.data.Model',
            fields: ['title', 'url']
        });

        Ext.define('FeedItem', {
            extend: 'Ext.data.Model',
            fields: ['title', 'author', 'link', {
                name: 'pubDate',
                type: 'date'
            }, {
                // Some feeds return the description as the main content
                // Others return description as a summary. Figure this out here
                name: 'description',
                mapping: function(raw) {
                    var DQ = Ext.dom.Query,
                        content = DQ.selectNode('content', raw),
                        key;

                    if (content && DQ.getNodeValue(content)) {
                        key = 'description';
                    } else {
                        key = 'title';
                    }
                    return DQ.selectValue(key, raw);

                }
            }, {
                name: 'content',
                mapping: function(raw) {
                    var DQ = Ext.dom.Query,
                        content = DQ.selectNode('content', raw);

                    if (!content || !DQ.getNodeValue(content)) {
                        content = DQ.selectNode('description', raw);
                    }
                    return DQ.getNodeValue(content, '');
                }
            }]
        });
        
        Ext.apply(this, {
            layout: {
                type: 'border',
                padding: 5
            },
            items: [this.createFeedPanel() ,this.createFeedInfo() ]
        });
        this.callParent(arguments);
    },
    
    /**
     * Create the list of fields to be shown on the left
     * @private
     * @return {FeedViewer.FeedPanel} feedPanel
     */
    createFeedPanel: function(){
        this.feedPanel = Ext.create('widget.menupanel', {
            region: 'west',
            collapsible: true,
            width: 225,
            //floatable: false,
            split: true,
            minWidth: 175,
            voci_menu: {
    		    "text":".",
    		    "children": 
    		        [
    		            {
    		                task:'Tabelle di base',  
    		                iconCls:'task-folder', 
    		                expanded: true,
    		                children:
    		                [
    		                 { 
                                 task:'Ship Owners',
                                 url: '/shipowners/extjs_sc_crt_tab', 
                                 leaf:true 
                             }, { 
                                 task:'Carriers',
                                 url: '/carriers/extjs_sc_crt_tab', 
                                 leaf:true 
                             }, { 
                                 task:'Equipment',
                                 url: '/equipment/extjs_sc_crt_tab', 
                                 leaf:true 
                             }, { 
                                 task:'Ports',
                                 url: '/ports/extjs_sc_crt_tab', 
                                 leaf:true 
                             }, { 
                                 task:'Shippers',
                                 url: '/shippers/extjs_sc_crt_tab', 
                                 leaf:true 
                             }, { 
                                 task:'Ships',
                                 url: '/ships/extjs_sc_crt_tab', 
                                 leaf:true 
                             }   		                 
    		                ]
                        }, {
                        task:'Movimenti',
                        iconCls:'task-folder',
                        expanded: true,
                        children:
                            [
                                {
                                    task:'Inserisci nuovo',
                                    leaf:true,
                                    iconCls:'task',
                                    op: 'NEW_HANDLING_HEADER'
                                }, {
                                task:'Handling Headers',
                                url: '/handling_headers/extjs_sc_crt_tab',
                                leaf:true
                            }
                            ]
                    }, {
                        task:'Import',
                        iconCls:'task-folder',
                        expanded: true,
                        children:
                            [
                                {
                                task:'Nuovo import',
                                url: '/import_headers/new_import',
                                leaf:true
                            }, {
                                task:'Apri import',
                                url: '/import_headers/find_import',
                                op: 'new_win',
                                leaf:true
                            }, {
                                task:'Elenco',
                                url: '/import_headers/extjs_sc_crt_tab',
                                leaf:true
                            }
                            ]
                    }, {
                        task:'Gestione Utenti',
                        iconCls:'task-folder',
                        expanded: true,
                        children:
                            [
                                {
                                task:'Users',
                                url: '/user_managers/extjs_sc_crt_tab',
                                leaf:true
                            }
                            ]
                    }
    		         ]
            },
            listeners: {
                scope: this,
                voce_menu_select: this.onVoceMenuSelect,
            }
        });
        return this.feedPanel;
    },
    
    /**
     * Create the feed info container
     * @private
     * @return {FeedViewer.FeedInfo} feedInfo
     */
    createFeedInfo: function(){
        this.feedInfo = Ext.create('Ext.tab.Panel', {
            region: 'center',
            minWidth: 300,
            items: [
            ]            
        });
        return this.feedInfo;
    },
    
    
    
/*    
    createNewTab: function(){
        this.newTab = Ext.create('FeedViewer.MovimentoPanel', {
			title: 'Movimento #123',
			closable: true			
        });
        
     return this.newTab;
    },
*/    	
	
	
    onVoceMenuSelect: function(menu, s, rec){
		//aggiungo al tab il nuovo panel
    	if (rec.get('op') == 'NEW_HANDLING_HEADER'){
    		//this.createNewTab();
			//this.feedInfo.add(this.newTab);
			//this.feedInfo.setActiveTab(this.newTab);
			
			//Mostro la win per inserire il codice container	        
	        Ext.create('FeedViewer.NewHandlingHeaderPanel').show();
			
			return;
    	}

    	
		if (rec.isLeaf() == true){
			if (rec.get('op') == 'new_win')
				acs_show_win_std(rec.get('task'), rec.get('url'), rec.get('jsonData'));			
			else				
    			acs_show_panel_std(this, rec.get('url'), {}, 'tttt');
			
			return;
		}	
    	
    },   
    
    
    
    /**
     * Reacts to a feed being selected
     * @private
     */
    onFeedSelect: function(feed, title, url){
        this.feedInfo.addFeed(title, url);
    }
});
