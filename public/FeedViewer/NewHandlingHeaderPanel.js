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
            height: 600,
    		width: 740
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

				
				{
					xtype: 'container',
					layout: {
        	    		type: 'hbox', align : 'stretch', pack: 'start'
        			},
					height: 150,
					items: [

			        	//ricerca numero container
			        	{
							xtype: 'form', border: true, flex: 1, bodyPadding: 10, margin: '0 5 0 0', buttonAlign : 'center', frame: true,							
							items: [        	
			        			{"fieldLabel":"Inserisci il numero container","name":"container_number", "xtype": "textfield", "labelAlign": "top", "anchor": "100%"},
			        			
								, {
						            xtype: 'radiogroup',
						            fieldLabel: '',
						            layout: 'hbox',
						            items: [{
						                boxLabel: 'Aperto',
						                name: 'status',
						                inputValue: 'OPEN',
						                checked: true,
						                width: 150                
						            }, {
						                boxLabel: 'Chiuso',
						                name: 'status',
						                inputValue: 'CLOSE'
						            }]
						        }
						        
			        		], 


						buttons: [
							{
				            text: 'Verifica',
				            handler: function (btn, evt) {              
								var l_form = this.up('form').getForm();
			    	            var l_grid = this.up('form').up('form').down('grid');
					             if (l_form.isValid()) {
			    					  l_grid.store.proxy.extraParams = {}	            	
			    			          l_grid.store.proxy.extraParams = l_form.getValues();
			    			          l_grid.store.load();				             
					             	}
				             	}
				            }							
						]
			        	}
			        	
			        	
			        	//ricerca per booking
			        	, {
							xtype: 'form', border: true, flex: 1, bodyPadding: 10, margin: '0 0 0 5', buttonAlign : 'center', frame: true,
							items: [        	
			        			{"fieldLabel":"Inserisci il numero di booking","name":"booking_number", "xtype": "textfield", "labelAlign": "top", "anchor": "100%"},			        			
			        		], 

						buttons: [
							{
				            text: 'Verifica',
				            handler: function (btn, evt) {              
								var l_form = this.up('form').getForm();
			    	            var l_grid = this.up('form').up('form').down('grid');
					             if (l_form.isValid()) {
			    					  l_grid.store.proxy.extraParams = {}	            	
			    			          l_grid.store.proxy.extraParams = l_form.getValues();
			    			          l_grid.store.load();				             
					             	}
				             	}
				            }							
						]			        		
			        	}			        	
			        ]
			    } 
	        		
	        		
	        	//GRID con movimenti per container	        		
					, {
						xtype: 'grid',
						loadMask: true,
						flex: 1,
						margin: '30 5 5 5',
						
						layout: {
                			type: 'vbox',
                			align: 'stretch'
     					},
									
						store: {
							xtype: 'store',
							autoLoad: false,	
							proxy: {
								url: 'terminal_movs/new_mov_search_handling', 
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
								  {header: 'Container', dataIndex: 'container_number', width: 80},
								  {header: 'Booking', dataIndex: 'num_booking', width: 80},
						          {header: 'Stato', dataIndex: 'stato_descr', width: 80},
								  {header: 'Azione', dataIndex: 'op_descr', width: 100},
						          ],
						
						
						listeners : {
						    itemdblclick: function(dv, rec, item, index, e) {
						    
						    	//Check Digit non valido
						    	if (parseInt(rec.get('valid_CD')) != 0){
									Ext.MessageBox.show({
				                        title: 'EXCEPTION',
				                        msg: 'Numero container non valido. Check Digit Error: ' + rec.get('valid_CD'),
				                        icon: Ext.MessageBox.ERROR,
				                        buttons: Ext.Msg.OK
			                    	});
			                    	return false;					    		
						    	}
						    	 
						    						    	
						        //Creo nuovo movimento
						        if (rec.get('op') == 'CRT'){
									new_rec = Ext.create('HandlingHeader', {});
						    		new_rec.set('id', null);
						    		new_rec.set('container_number', rec.get('container_number'));
						    		new_rec.set('handling_status', 'CRT');
							        newPanel = Ext.create('FeedViewer.MovimentoPanel', {
										title: 'Movimento #123',
										closable: true			
							        });
							     } 
							     
							    //Carico il movimento e lo apro in gestione 
						        if (rec.get('op') == 'EDIT'){						         
									new_rec = HandlingHeader.load(rec.get('handling_id'));
							        newPanel = Ext.create('FeedViewer.MovimentoPanel', {
										title: 'Movimento #123',
										closable: true			
							        });
							     }							     
							       
			                		newPanel.getViewModel().setData({rec: new_rec, 
			                			is_handling_editable: rec.get('op') == 'CRT' ? true : false,
			                			is_container_editable: rec.get('is_container_editable')
			                		});
			                    	myApp.feedInfo.add(newPanel).show();
									//mostro il tab appena aggiunto (l'ultimo)
						            myApp.feedInfo.setActiveTab(myApp.feedInfo.items.length - 1);			                    	
			                    	this.close();						         
						        
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
