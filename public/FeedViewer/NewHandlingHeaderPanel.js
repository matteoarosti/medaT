/**
 * @class FeedViewer.FeedPanel
 * @extends Ext.panel.Panel
 *
 * Shows a list of available feeds. Also has the ability to add/remove and load feeds.
 *
 * @constructor
 * Create a new Feed Panel
 * @param {Object} config The config object
 */

Ext.define('FeedViewer.NewHandlingHeaderPanel', {
    extend: 'Ext.window.Window',

    alias: 'widget.newhandlingheaderpanel',

    animCollapse: true,
    layout: 'fit',
    title: 'Inserimento nuovo movimento',
    modal: true,

    /**
     * @event feedremove Fired when a feed is removed
     * @param {FeedPanel} this
     * @param {String} title The title of the feed
     * @param {String} url The url of the feed
     */

    /**
     * @event feedselect Fired when a feed is selected
     * @param {FeedPanel} this
     * @param {String} title The title of the feed
     * @param {String} url The url of the feed
     */

    initComponent: function(){
        Ext.apply(this, {
            items: this.createView(),
            height: 300,
    		width: 540
        });
        this.callParent(arguments);
    },

    /**
     * Create the DataView to be used for the feed list.
     * @private
     * @return {Ext.view.View}
     */
    createView: function(){
    	    	    	
    	
        this.view = Ext.create('Ext.form.Panel', {
        	bodyPadding: 10,
        	layout: {
        	    type: 'vbox', align : 'stretch', pack: 'start'
        	},
        	items: [

	        	//ricerca numero container
	        		{
					xtype: 'fieldset', border: false, flex: 1,
					items: [        	
	        			{"fieldLabel":"Inserisci il numero container","name":"container_number", "xtype": "textfield", "labelAlign": "top", "anchor": "100%"},
	        			{xtype: "button", text: "Verifica e inserisci", iconCls: 'fa fa-search', handler: function() {
	    	            	var l_form = this.up('form').getForm();
	    	            	var l_grid = this.up('panel').down('grid');

		    					if(l_form.isValid()){	            	
		    			          l_grid.store.proxy.extraParams.container_number = l_form.findField('container_number').getValue();
		    			          l_grid.store.load();
		    				    }            	                	                
		    	            }
	        				
	        			}
	        		]} 
	        		
	        		
	        	//GRID con movimenti per container	        		
					, {
						xtype: 'grid',
						loadMask: true,
						flex: 1,
						
						layout: {
                			type: 'vbox',
                			align: 'stretch'
     					},
									
						store: {
							xtype: 'store',
							autoLoad: false,	
							proxy: {
								url: 'terminal_movs/new_mov_search_container_number', 
								extraParams: {container_number: null},
								method: 'POST',
								type: 'ajax',
					
								//Add these two properties
								actionMethods: {
									read: 'POST'
								},
					
								reader: {
									type: 'json',
									method: 'POST',
									rootProperty: 'items'
								}
							},
								
							fields: [] //serve
						}, //store
						columns: [{header: 'Movimento', dataIndex: 'descr', flex: 1},
						          {header: 'Stato', dataIndex: 'stato_descr', width: 80},
								  {header: 'Azione', dataIndex: 'op_descr', width: 80},
						          ],
						
						
						listeners : {
						    itemdblclick: function(dv, rec, item, index, e) {
						        //apro il movimento
						        if (rec.get('stato') == 'CRT'){
									new_rec = Ext.create('HandlingHeaders', {});
						    		new_rec.set('id', null);
						    		new_rec.set('container_number', rec.get('container_number'));
						    		new_rec.set('handling_status', 'CRT');
							        newPanel = Ext.create('FeedViewer.MovimentoPanel', {
										title: 'Movimento #123',
										closable: true			
							        });
			                		newPanel.getViewModel().setData({rec: new_rec, 
			                			is_handling_editable: true,
			                			is_container_editable: true
			                		});
			                    	myApp.feedInfo.add(newPanel).show();
			                    	this.close();						         
						        }
						    }, scope: this
						}						 
					}	        		
	        		
	        		
	        		
	        		
	        		
        		
        		//HELP
	        		, {
	        		  layout: 'fit', heigt: 50, cls: 'app_info', border: true,
					  html: '<i class="fa fa-info-circle"></i>Verrà ricercato il movimento aperto relativo al numero container inserito<br/> o verrà generato un nuovo movimento'
					}
        		
        	]
        	});
        return this.view;
    },

    onViewReady: function(){
    },


    // Inherit docs
    onDestroy: function(){
        this.callParent(arguments);
    }
});
