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
    		width: 940
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
			        			{"fieldLabel":"Inserisci il numero container/booking","name":"search_number", "xtype": "textfield", "labelAlign": "top", "anchor": "100%",
									listeners: {
									    'change': function(){
											var l_form = this.up('form').getForm();
						    	            var l_grid = this.up('form').up('form').down('grid');
								             if (l_form.isValid()) {
						    					  l_grid.store.proxy.extraParams = {}	            	
						    			          l_grid.store.proxy.extraParams = l_form.getValues();
						    			          l_grid.store.load();				             
								             	}									      
									    }
									  }			        			
			        			},
			        			
			        			
								{
					                xtype: 'fieldcontainer',
					                fieldLabel: '',
					                combineErrors: true,
					                msgTarget : 'side',
					                layout: 'hbox',
					                anchor: '100%',
					                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
					                items: [
					                
										{
								            xtype: 'radiogroup',
								            fieldLabel: '',
								            layout: 'hbox',
								            flex: 1,
								            items: [{
								                boxLabel: 'Aperto',
								                name: 'status',
								                inputValue: 'OPEN',
								                checked: true,
								                width: 90                
								            }, {
								                boxLabel: 'Chiuso',
								                name: 'status',
								                inputValue: 'CLOSE',
								                width: 90
								            }, {
								                boxLabel: 'Entrambi',
								                name: 'status',
								                inputValue: '',
								                width: 90
								            }]
								        },
								        
										{
								            xtype: 'radiogroup',
								            fieldLabel: '',
								            layout: 'hbox',
								            flex: 1,
								            items: [{
								                boxLabel: 'Container',
								                name: 'search_type',
								                inputValue: 'container',
								                checked: true,
								                width: 130                
								            }, {
								                boxLabel: 'Booking',
								                name: 'search_type',
								                inputValue: 'booking',
								                width: 130
								            }]
								        }								        								       								        
				                        

									]
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
			        	

/*			        	
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
*/
			        	
			        	
			        			        	
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
								url: myApp.railsBaseUri + 'terminal_movs/new_mov_search_handling', 
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
								  {header: 'Container', dataIndex: 'container_number', width: 140},
								  {header: 'P/V', dataIndex: 'container_FE', width: 40},
								  {header: 'Tipo', dataIndex: 'equipment_id_Name', width: 60},
								  {header: 'Booking', dataIndex: 'num_booking', width: 100},
								  {header: 'Compagnia', dataIndex: 'shipowner_id_Name', width: 80},
								  {header: 'Ultimo agg.', dataIndex: 'updated_at', width: 90, xtype: 'datecolumn'},
						          {header: 'Stato', dataIndex: 'stato_descr', width: 80, 
						        	renderer: function(value, metaData, rec, rowIndex, colIndex, store) {
						        		v = value;
						        		if (rec.get('lock_fl') == true)
						        			v = v + '<br>' + rec.get('lock_type');
						        		return v;
						        	}
						          },
								  {header: 'Azione', dataIndex: 'op_descr', width: 80},
						          ],
						
						
						listeners : {
						    itemdblclick: function(dv, rec, item, index, e) {
						    
						    	//Check Digit non valido
						    	if (rec.get('op') == 'CRT' && parseInt(rec.get('valid_CD')) != 0){
									Ext.Msg.confirm({
				                        title: 'EXCEPTION',
				                        msg: 'Numero container non valido. Check Digit Error: ' + rec.get('valid_CD') + '<BR/>Proseguire ugualmente?',
				                        icon: Ext.MessageBox.ERROR,
				                        buttons: Ext.Msg.YESNO,
										fn: function(btn){                    
										         if (btn == "no"){ //NO, esco
										           return false;              
										        }
										        if (btn == "yes"){ //YES, proseguo
										            
												        //Creo nuovo movimento
												        if (rec.get('op') == 'CRT'){
															new_rec = Ext.create('HandlingHeader', {});
												    		new_rec.set('id', null);
												    		new_rec.set('container_number', rec.get('container_number'));
												    		new_rec.set('handling_status', 'CRT');
													        newPanel = Ext.create('FeedViewer.MovimentoPanel', {
																title: 'Mov. ' + rec.get('container_number'),
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
																		     
													 return false;    
													     								                       
										        }
										   }, scope: this   
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
										title: 'Mov. ' + rec.get('container_number'),
										closable: true			
							        });
							     } 
							     
							    //Carico il movimento e lo apro in gestione 
						        if (rec.get('op') == 'EDIT'){						         
									new_rec = HandlingHeader.load(rec.get('handling_id'));
							        newPanel = Ext.create('FeedViewer.MovimentoPanel', {
										title: 'Mov. ' + rec.get('container_number'),
										closable: true			
							        });
							     }							     
							       
						        if (rec.get('op') == 'VIEW'){						         
									new_rec = HandlingHeader.load(rec.get('handling_id'));
							        newPanel = Ext.create('FeedViewer.MovimentoPanel', {
										title: 'Mov. ' + rec.get('container_number'),
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
