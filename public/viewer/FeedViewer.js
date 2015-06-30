Ext.define('FeedViewer.App', {
	appFolder: '../FeedViewer',
	requires : [],
    extend: 'Ext.container.Viewport',
    railsBaseUri: 'aaaaaaaaa',
    
    initComponent: function(){
	
		this.railsBaseUri = this.initialConfig.railsBaseUri;
		this.railsUser    = this.initialConfig.railsUser;
		this.canModifyHandling = this.initialConfig.canModifyHandling;
	
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
    		    "children": this.initialConfig.voci_menu
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
    
  	
	
	
    onVoceMenuSelect: function(menu, s, rec){
		//aggiungo al tab il nuovo panel

		if (rec.get('op') == 'USERS'){
		 window.location = myApp.railsBaseUri + 'users';
		 return;
		}	

		
		if (rec.get('op') == 'LOGOUT'){
			Ext.Ajax.request({
				url: myApp.railsBaseUri + 'users/sign_out', //LOGOUT URL
				method: 'delete',
				success : function() {
					window.location = myApp.railsBaseUri + 'users/sign_in'; //the location you want your browser to be  redirected.
				},
				params: {}
			});
		 return;
		}	
		
		
		
    	if (rec.get('op') == 'NEW_HANDLING_HEADER'){
						
			//se gia' esiste eseguo la show del tab						
			if (Ext.getCmp('main_panel_handling_search')){
				Ext.getCmp('main_panel_handling_search').show();
				Ext.getCmp('main_panel_handling_search').down('form').getForm().findField('search_number').focus();
				return;		    	
			}
			
			this.m_panel_NewHandlingHeader = Ext.create('FeedViewer.NewHandlingHeaderPanel');
			this.feedInfo.add(this.m_panel_NewHandlingHeader);
			this.feedInfo.setActiveTab(this.m_panel_NewHandlingHeader);
			//this.m_panel_NewHandlingHeader.fireEvent('onShow');
						
			return;
    	}

    	
		if (rec.isLeaf() == true){
			if (rec.get('op') == 'new_win')
				acs_show_win_std(rec.get('task'), rec.get('url'), rec.get('jsonData'), rec.get('width'), rec.get('height'));			
			else if (rec.get('op') == 'new_page')
				window.open(rec.get('url'), "_blank")
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
