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

Ext.define('FeedViewer.MovimentoPanel', {
    extend: 'Ext.panel.Panel',

    alias: 'panel.movimentopanel',

    animCollapse: true,
    layout: 'fit',
    title: 'Menu',
    
	viewModel: {
    			data: {
    				rec: null,
    				is_handling_editable: false,
    				is_container_editable: false
    			}, 
    			formulas: {
    		        // We'll explain formulas in more detail soon.
    		        is_rec_crt:{
    		          bind: {bindTo: '{rec}'},
    		          get: function (rec) {
    		        	if (rec){
    		        	 if (rec.get('handling_status') == 'CRT')
    		        		 return true;
    		        	}
    		        	return false;
    		            //return (get.rec.get('container_status') == 'ANEW') ? true : false;
    		        }
    		       }
    			
    		    }    			
    		},    

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
            items: this.createView()
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
        	layout: {
        	    type: 'vbox',
        	    align : 'stretch',
        	    pack  : 'start',
        	},
        	listeners: {
	            afterrender: function (comp) {
	            	//associo i dettagli al record caricato
	                comp.down('gridpanel').store.proxy.extraParams.handling_id = this.getViewModel().getData().rec.id;
	                comp.down('gridpanel').store.reload();
	            }, scope: this 	
        	},
        	items:[{
        	    title: '', //flex: 40,
        	    xtype: 'panel',
        	    bodyStyle: 'padding: 5px',        	    
            	layout: {
            	    type: 'hbox',
            	    align : 'stretch',
            	    pack  : 'start',
            	},        	    
        	    items: [
        	     {         
        	    	 flex: 1,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Dati generali e container',
                     //combineErrors: true,
                     //msgTarget : 'side',
                 	layout: {
                	    type: 'vbox',
                	    //align : 'stretch',
                	    pack  : 'start',
                	},
                     defaults: {
                         //flex: 1,
                         hideLabel: false,
                         labelWidth: 140,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [
                        {fieldLabel: 'id', bind: '{rec.id}', disabled: true},
                        {fieldLabel: 'handling_status', bind: '{rec.handling_status}', disabled: true},
                        {fieldLabel: 'handling_type', xtype: 'combo',
                        	bind: {value: '{rec.handling_type}', disabled: '{!is_handling_editable}'},
                        	displayField: 'descr', valueField: 'cod',                        	
                        	store: {
                        	  fields: ['cod', 'descr'],
                        	  data: [ 
                        	         {cod: 'TMOV', descr: 'Movimento terminal'},
                        	         {cod: 'FRCON', descr: 'Allaccio frito'},
                        	         {cod: 'INSPE', descr: 'Visita doganale'}
                        	  ]
                        	}
                        },
                        
						{
							xtype: 'combobox',
							fieldLabel: 'Compagnia',
							displayField : 'short_name',
							valueField:  'id',
							forceSelection: true,
							triggerAction: 'all',  
							
								store: Ext.create('Ext.data.Store', {
								    model: 'Shipowner', autoLoad: true,
								    proxy: {
								        type: 'ajax',
								        url: '/shipowners/get_combo_data',
								        reader: {
								            type: 'json',
								            rootProperty: 'items'
								        }       
								    },			    
								}), 					
							 bind: {value: '{rec.shipowner_id}', disabled: '{!is_container_editable}'}						  
							},




                        {
                        	xtype: 'fieldcontainer',
                        	layout: {
                        	    type: 'hbox',
                        	},                        	
                            defaults: {
                            	 xtype: 'textfield',
                            	 labelWidth: 140
                            },                        	
                        	items: [
                        	  {
								xtype: 'combobox',
								fieldLabel: 'Tipo container',
								displayField : 'equipment_type',
								valueField:  'id',
								forceSelection: true,
								triggerAction: 'all',  
								
									store: Ext.create('Ext.data.Store', {
									    model: 'Equipment',
									    autoLoad: true,							    
									    proxy: {
									        type: 'ajax',
									        url: '/equipment/get_combo_data',
									        reader: {
									            type: 'json',
									            rootProperty: 'items'
									        }       
									    },			    
									}), 					
								 bind: {value: '{rec.equipment_id}', disabled: '{!is_container_editable}'}						  
							  },  
                        	  //{fieldLabel: 'OH', width: 90, labelWidth: 40, labelAlign: 'right', anchor: '-10', bind: {value: '{rec.container_OH}', disabled: '{!is_container_editable}'}}
                        	]
                        },
                        {fieldLabel: 'container_number', bind: '{rec.container_number}', disabled: true},
                        {fieldLabel: 'container_status', margin: '1 0 5 0', bind: '{rec.container_status}', disabled: true}
                        
                        
                        
                     ]
        	     }, {         
        	    	 flex: 1,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Dati viaggio',
                     //combineErrors: true,
                     //msgTarget : 'side',
                 	layout: {
                	    type: 'vbox',
                	    //align : 'stretch',
                	    pack  : 'start',
                	},
                     defaults: {
                         //flex: 1,
                         hideLabel: false,
                         labelWidth: 140,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [
                        {fieldLabel: 'Booking', disabled: true, bind: {value: '{rec.booking_id_Name}'}},
                        {fieldLabel: 'Destinazione'},
                        {fieldLabel: 'Sigillo Esp.1', disabled: true, bind: {value: '{rec.seal}'}},                        
                        {fieldLabel: 'ID FM'}                        
                     ]
        	     }, {         
        	    	 width: 200,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Azioni',
                     //combineErrors: true,
                     //msgTarget : 'side',
                 	layout: {
                	    type: 'hbox',
                	    //align : 'stretch',
                	    pack  : 'start',
                	},
                     defaults: {
                         //flex: 1,
                         hideLabel: false,
                         labelWidth: 140,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [

 						{ xtype : "button", text : 'Salva', flex: 1,
 							
						    bind: {
								visible: '{is_handling_editable}'
							},						    
 							
 							
 							handler: function(){
						    rec = this.getViewModel().getData().rec;
						    form = this.down('form').getForm();
						    
		    				 if (form.isValid()) { 
		    					 this.getViewModel().getData().rec.save({
									success: function(rec, op) {										
									//TODO: aggiorno il recordset con il record ritornato dal server (per id, updated_at...)
									//this.getViewModel().getData().rec.set('handling_status', 'NEW');
									this.getViewModel().setData({is_handling_editable: false});
									this.getViewModel().setData({is_container_editable: false});
									
									var result = Ext.JSON.decode(op.getResponse().responseText);									
									
									rec.set(result.data[0]);
									this.getViewModel().setData({rec: rec});
												
									//imposto handling_id anche sulla grid di dettaglio
									this.down('gridpanel').store.proxy.extraParams.handling_id = rec.id
									this.down('gridpanel').store.reload()
																		
									this.doLayout();									
									}, scope: this,
		    					 
		    					 });
		    				 }						    
						    
						    			    			
						 }, scope: this }
                                                
                     ]
        	     }
        	     
        	     
        	    ]
        	}
        	
        	
        	
        	, {
        	    title: 'Distinta movimenti', flex: 50,
        	    tools: [{  
		                xtype: 'button',
		                text: 'Aggiungi <i class="fa fa-plus-circle"></i>',
		                //, iconCls: 'fa fa-plus-circle fa-lg', xxx
		                handler: function(){	
		                	acs_show_win_std('Seleziona tipo dettaglio', '/terminal_movs/add_handling_items_select_type',
		                		 {rec_id: this.getViewModel().getData().rec.get('id')},
		                		 null, null, null, null, null, null, {mov_panel: this});
		                }, scope: this
		            }
                ],
        	    xtype: 'gridpanel',
        	    store: new Ext.data.Store({
        	    	autoLoad: false,
        	    	fields: [],
        	    	proxy: {
        	            type: 'ajax',
        	            url: '/handling_headers/hitems_sc_list',
        	            reader: {
        	                type: 'json',
        	                rootProperty: 'items'
        	            }
        	        },
        	        data: {
        	            'items': [
        	            	{'seq': 1, 'data':  new Date(2011,11,30, 5, 6, 7), "eu": 'E', "pv": 'P', nave: 'MSC ANASTASIA', voy: '247rjk'},
							{'seq': 2, 'data':  new Date(2011,11,30, 5, 6, 7), "eu": 'U', "pv": 'P', vettore: 'ABC', autista: 'autista 1'},
							{'seq': 3, 'data':  new Date(2011,11,30, 5, 6, 7), "eu": 'E', "pv": 'V', vettore: 'ABC', autista: 'autista 1'},
							{'seq': 4, 'data':  new Date(2011,11,30, 5, 6, 7), "eu": 'U', "pv": 'V', vettore: 'VVV', autista: 'autista 2'},
							{'seq': 5, 'data':  new Date(2011,11,30, 5, 6, 7), "eu": 'E', "pv": 'P', vettore: 'VVV', autista: 'autista 2'},
        	            	{'seq': 6, 'data':  new Date(2011,11,30, 5, 6, 7), "eu": 'U', "pv": 'P', nave: 'MSC GIULIA', voy: '235A'}							
        	            ]
        	        }
        	    }),
        	    columns: [
        	       {text: 'P', width: 25, dataIndex: 'seq', renderer : function(value, metaData, record, rowIndex)
						    {
						        return rowIndex + 1;
						    }},
        	       {text: 'Data/ora', width: 160, dataIndex: 'datetime_op', xtype:  'datecolumn', format: 'd-m-Y H:i:s'},
        	       {text: 'Op', width: 160, dataIndex: 'handling_item_type', width: 100},        	        
        	       {text: 'E/U', width: 40, dataIndex: 'handling_type', tooltip: 'Entrata / Uscita', tdCls: 'm-only-icon', renderer: function(value, metaData){return this.get_image_IO(value, metaData);}},
                   {text: 'P/V', width: 40, dataIndex: 'container_FE', tooltip: 'Pieno / Vuoto', tdCls: 'm-only-icon', renderer: function(value, metaData){return this.get_image_FE(value, metaData);}},
				   {text: 'Nave', width: 130, dataIndex: 'ship_id_Name'},
				   {text: 'Voy', width: 60, dataIndex: 'voyage'},
				   {text: 'Vettore', width: 130, dataIndex: 'carrier_id_Name'},                				                      				                      
				   {text: 'Autista', flex: 1, dataIndex: 'driver'},
				   {text: 'Sigillo', width: 80, dataIndex: 'seal'},
				   {text: 'Imb', width: 50, dataIndex: 'imb', xtype: 'checkcolumn'},				                   				                      				                      				   
				   {text: 'MP', width: 50, dataIndex: 'mp', xtype: 'checkcolumn'},				                   				                      				                      				   
				   {text: 'IMO', width: 50, dataIndex: 'imo', xtype: 'checkcolumn'}
        	       ],
        	       
				get_image_IO: function(val, metaData){
					if (val == 'I') metaData.tdAttr = 'data-qtip="Entrata"';
					if (val == 'O') metaData.tdAttr = 'data-qtip="Uscita"';					
					
	 				if (val == 'I') return '<i class="fa fa-download fa-2x" style="color:green;"></i>';
	 				if (val == 'O') return '<i class="fa fa-upload fa-2x" style="color:red;"></i>';
				},
				get_image_FE: function(val, metaData){
					if (val == 'F') metaData.tdAttr = 'data-qtip="Pieno"';
					if (val == 'E') metaData.tdAttr = 'data-qtip="Vuoto"';					
					
					if (val == 'F') return '<i class="fa fa-square fa-2x" style="color:brown;"></i>';
					if (val == 'E') return '<i class="fa fa-square-o fa-2x" style="color:brown;"></i>';
				},
        	       
                        	    
        	}        	
        	
        	
        	
        	
        	]
        });
        return this.view;
    },

    onViewReady: function(){
     console.log('onViewReady');
     console.log(this);
    },


    // Inherit docs
    onDestroy: function(){
        this.callParent(arguments);
    }
});
