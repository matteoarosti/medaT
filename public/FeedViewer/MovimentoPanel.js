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

    				
    				//puo' essere modificato? (verifico anche i permessi utente)
    				is_handling_modify_can:{
    		          bind: {bindTo: '{is_handling_editable}', deep: true},
    		          get: function (is_handling_editable) {
    		        	  
    		        	  if (myApp.canModifyHandling == false)
    		        		return false;
    		        	    		        	
    		        	if (is_handling_editable == false) return true;
    		        	return false;

    		        }
    		       },
    		       
    		       
    				
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
    		       },

    		       
       		    //TODO: DRY
   		        icon_handling_status:{
     		          bind: {bindTo: '{rec}', deep: true},
     		          get: function (rec) {
     		        	if (rec){
     		        		if (rec.get('handling_status') == 'OPEN') 	return '<i class="fa fa-circle-o fa-2x" style="color:green;"></i>';
     		        		if (rec.get('handling_status') == 'CLOSE')	return '<i class="fa fa-times fa-2x" style="color:gray;"></i>';
     		        		if (rec.get('handling_status') == 'NEW') 	return '<i class="fa fa-plus fa-2x" style="color:blue;"></i>';
     		        		if (rec.get('handling_status') == 'CRT') 	return '<i class="fa fa-plus fa-2x" style="color:red;"></i>';
     		        		return rec.get('handling_status');
     		          	}
     		        	return '';
     		            //return (get.rec.get('container_status') == 'ANEW') ? true : false;
     		        }
     		       },
    		       

          		    //TODO: DRY
      		        icon_container_FE:{
        		          bind: {bindTo: '{rec}', deep: true},
        		          get: function (rec) {
        		        	if (rec){
        						if (rec.get('container_FE') == 'F') return '<i class="fa fa-square fa-2x" style="color:brown;"></i>';
        						if (rec.get('container_FE') == 'E') return '<i class="fa fa-square-o fa-2x" style="color:brown;"></i>';					
        		          	}
        		        	return '<i class="fa fa-square-o fa-2x" style="color:transparent;"></i>';
        		        }
        		       },
     		       

        		       
             		    //TODO: DRY
         		        icon_container_in_terminal:{
           		          bind: {bindTo: '{rec}', deep: true},
           		          get: function (rec) {
           		        	if (rec){
           						if (rec.get('container_in_terminal') == true) return '<i class="fa fa-download fa-2x" style="color:green;"></i>';
           						if (rec.get('container_in_terminal') == false) return '<i class="fa fa-upload fa-2x" style="color:red;"></i>';
           		          	}
           		        	return '';
           		        }
           		       },
        		       
        		       
    		       
	    		    //TODO: DRY
			        icon_lock_type:{
	     		      bind: {bindTo: '{rec}', deep: true},
	  		          get: function (rec) {
	  		        	if (rec){	  		        		
	  		        		return pb_get_image_lock(rec.get('lock_type'));	  		        			  		        			  		        		
	  		        	}
	  		        	return '';
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
                 	 /*layout: {                 		
                	    type: 'hbox',
                	    align : 'stretch',
                	    pack  : 'start',
                	 },*/
                     defaults: {
                         //flex: 1,
                         hideLabel: false,
                         labelWidth: 140,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [
                        
                        
						{	
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Handling id / Type',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', hideLabel: true},
			                items: [
		                        {fieldLabel: 'id', bind: '{rec.id}', disabled: true, width: 70},
		                        {fieldLabel: 'handling_type', xtype: 'combo', flex: 1,
		                        	bind: {value: '{rec.handling_type}', disabled: '{!is_handling_editable}'},
		                        	displayField: 'descr', valueField: 'cod', 
		                        	anchor: '100%',                       	
		                        	store: {
		                        	  fields: ['cod', 'descr'],
		                        	  data: [ 
		                        	         {cod: 'TMOV', descr: 'Mov. terminal'},
		                        	         {cod: 'FRCON', descr: 'Allaccio frigo'},
		                        	         {cod: 'INSPE', descr: 'Visita doganale'},
		                        	         {cod: 'OLOAD', descr: 'Imb. c/o altro term.'}
		                        	  ]
		                        	}
		                        }		                        
		                        
							]
						},                         
                        
                        
                        
			            
			            
			            
			            
						{
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Shipowner/Equip.',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
								{
									xtype: 'combobox',
									fieldLabel: 'Compagnia',
									displayField : 'short_name',
									valueField:  'id',
									forceSelection: true,
									triggerAction: 'all',
					                anchor: '100%',							  
									
										store: Ext.create('Ext.data.Store', {
										    model: 'Shipowner', autoLoad: true,
										    proxy: {
										        type: 'ajax',
										        url: myApp.railsBaseUri + 'shipowners/get_combo_data',
										        reader: {
										            type: 'json',
										            rootProperty: 'items'
										        }       
										    },			    
										}), 					
									 bind: {value: '{rec.shipowner_id}', disabled: '{!is_handling_editable}'}						  
									},
		                        	  {
										xtype: 'combobox',
										fieldLabel: 'Tipo container',
										displayField : 'equipment_type',
										valueField:  'id',
										forceSelection: true,
										triggerAction: 'all',  
					                	anchor: '100%',								
										
											store: Ext.create('Ext.data.Store', {
											    model: 'Equipment',
											    autoLoad: true,							    
											    proxy: {
											        type: 'ajax',
											        url: myApp.railsBaseUri + 'equipment/get_combo_data',
											        reader: {
											            type: 'json',
											            rootProperty: 'items'
											        }       
											    },			    
											}), 					
										 bind: {value: '{rec.equipment_id}', disabled: '{!is_handling_editable}'}						  
									  },									
			                ]
			            },			            
                        


						{
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Container number',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'container_number', bind: '{rec.container_number}', disabled: true}
							]
						}
						
						
/*						
						, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Container status',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'container_status', bind: '{rec.container_status}', disabled: true}
							]
						}
*/
                        
						, {xtype: 'tbfill', height: 20}
						
						, {
			                xtype: 'fieldcontainer',
			                frame: false,
			                //fieldLabel: 'Stato / Lock',
			                layout: 'hbox',
			                anchor: '100%',
			                width: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
			                        {xtype: "panel", bind: '{icon_handling_status} {rec.handling_status}'},
			                        {xtype: "panel", bind: '{icon_container_FE}'},
			                        {xtype: "panel", bind: '{icon_container_in_terminal}'},
			                        {xtype: "panel", bind: '{icon_lock_type} {rec.lock_type}'}			                        			                
			                ]
			            }
										
						
                     ]
        	     }, 
        	     
        	     
        	     {         
        	    	 width: 280,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Fase di Import',
                     defaults: {
                         hideLabel: false,
                         labelWidth: 100,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [
                     
						{
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Seal ShipOwn.',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'Seal ShipOwn', anchor: '100%', disabled: true, bind: {value: '{rec.seal_imp_shipowner}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Seal others',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'Seal Others', anchor: '100%', disabled: true, bind: {value: '{rec.seal_imp_others}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Temp./Weight',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.temperature_imp}'}},
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.weight_imp}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'IMO',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.imo_imp}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Bill of lading',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.bill_of_lading}'}}
							]
						}                                               
                     ]
        	     }, 
        	     
        	     
        	     
    	     
        	     {         
        	    	 width: 280,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Fase di Export',
                     defaults: {
                         hideLabel: false,
                         labelWidth: 100,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [
                     
						{
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Seal ShipOwn.',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'Seal ShipOwn', anchor: '100%', disabled: true, bind: {value: '{rec.seal_exp_shipowner}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Seal others',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'Seal Others', anchor: '100%', disabled: true, bind: {value: '{rec.seal_exp_others}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Temp./Weight',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.temperature_exp}'}},
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.weight_exp}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'IMO',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {anchor: '100%', disabled: true, bind: {value: '{rec.imo_exp}'}}
							]
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Booking',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: {
			            	    type: 'hbox',
			            	    align : 'stretch',
			            	    pack  : 'start',
			            	},
			                anchor: '100%',
			                defaults: {xtype: 'textfield', hideLabel: true},
			                items: [
		                        { flex: 1, fieldLabel: 'Booking', disabled: true, bind: {value: '{rec.booking_id_Name}'}},		                       
		                        { xtype : "button", text : '?', flex: 0.3,		 									 								 							
		 							handler: function(){
								    rec = this.getViewModel().getData().rec;
								    
								    if (rec.get('booking_item_id') === null)
								      return false;
								    
								    acs_show_win_std('Info dettaglio booking', myApp.railsBaseUri + 'bookings/bitem_info',
					                		 {rec_id: rec.get('booking_item_id')},
					                		 700, 500, null, null, null, null, {mov_panel: this});
		 							}, scope: this
		                        }
							]										                
						}, {
			                xtype: 'fieldcontainer',
			                fieldLabel: 'Nave / Viaggio',
			                combineErrors: true,
			                msgTarget : 'side',
			                layout: 'hbox',
			                anchor: '100%',
			                defaults: {xtype: 'textfield', flex: 1, hideLabel: true},
			                items: [
		                        {fieldLabel: 'Nave', disabled: true, bind: {value: '{rec.booking.ship.name}'}},
		                        {fieldLabel: 'Viaggio', disabled: true, bind: {value: '{rec.booking.voyage}'}}
							]
						}
                                                                        
                     ]
        	     }, 
        	     

        	     
        	     
        	     
        	     {         
        	    	 width: 100,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Azioni',
                     //combineErrors: true,
                     //msgTarget : 'side',
                 	layout: {
                	    type: 'vbox',
                	    //align : 'stretch',
                	    //pack  : 'start',
                	},
                     defaults: {
                         //flex: 1,
                         hideLabel: false,
                         labelWidth: 140,
                     	 xtype: 'textfield',
                     	 margin: '1 0 0 0'
                     },
                     items: [

 						{ xtype : "button", text : 'Salva', width: '100%',
 							
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
									//this.getViewModel().applyFormulas(['abcde.aaa']);
												
									//imposto handling_id anche sulla grid di dettaglio
									this.down('gridpanel').store.proxy.extraParams.handling_id = rec.id
									this.down('gridpanel').store.reload()
																		
									this.doLayout();									
									}, scope: this,
									
									
									
									failure: function(rec, op) {
										var result = Ext.JSON.decode(op.getResponse().responseText);
										Ext.MessageBox.show({
					                        title: 'EXCEPTION',
					                        msg: result.message,
					                        icon: Ext.MessageBox.ERROR,
					                        buttons: Ext.Msg.OK
				                    	})					

									}, scope: this
									
		    					 
		    					 });
		    				 }						    
						    
						    			    			
						 }, scope: this },
						 
						 
						 
 						{ xtype : "button", text : 'Modifica', width: '100%',
 							
						    bind: {
								//visible: '{!is_handling_editable}'
						    	visible: '{is_handling_modify_can}'
							},						    
 							
 							
 							handler: function(){
			                	acs_show_win_std('Modifica handling header', myApp.railsBaseUri + 'handling_headers/edit_header',
			                		 {rec_id: this.getViewModel().getData().rec.get('id')},
			                		 700, 500, null, null, null, null, {mov_panel: this});
						    }, scope: this
						}
						 
						 ,
						 
						 
						 {		xtype: 'button',
					            text: 'Elimina',  cls: 'btn-del',  width: '100%',
					            
					            bind: {
									//visible: '{!is_handling_editable}'
							    	visible: '{is_handling_modify_can}'
								},					            
					            
					            handler: function (btn, evt) {              					             
					             
					            	  m_view = this;
					             	  panel = this;
									  Ext.MessageBox.confirm('Richieta conferma', 'Eliminare il movimento corrente e i suoi dettagli?', function(btn){
									   if(btn === 'yes'){
									   
							             	new_rec = Ext.create('HandlingHeader', {});
							             	//devo inizializzare anche uno store altrimenti (se il model non e' mai stato usato) non ha le info sul proxy
							             	new Ext.data.Store({
											    autoLoad: false,
											    model: 'HandlingHeader'
											});
											
											Ext.Ajax.request({
							                    url: new_rec.proxy.api.destroy,
							                    waitMsg: 'Salvataggio in corso....',
												method:'POST',                     
							                    jsonData: {data: m_view.getViewModel().getData().rec.data},	
							             	
												success: function(result, request) {
														var returnData = Ext.JSON.decode(result.responseText);
														if (returnData.success == false){
															Ext.MessageBox.show({
										                        title: 'EXCEPTION',
										                        msg: returnData.message,
										                        icon: Ext.MessageBox.ERROR,
										                        buttons: Ext.Msg.OK
									                    	})
									                      return false;										
														}								
												
												
													panel.destroy();						 							
												},
												
												failure: function(rec, op) {
													var result = Ext.JSON.decode(op.getResponse().responseText);
													Ext.MessageBox.show({
								                        title: 'EXCEPTION',
								                        msg: result.message,
								                        icon: Ext.MessageBox.ERROR,
								                        buttons: Ext.Msg.OK
							                    	})					
												}, scope: this,						
																 
									    	});	             

									   } 
									   else{
									      //some code
									   }
									 }); //yes
				             
					            }, scope: this
					        },	
						 
						 
					        {xtype: 'tbfill', height: '30px'}, 
						 
	 						{ xtype : "button", text : 'Chiudi', width: '100%',
					        	cls: 'btn-used', scale: 'medium',
	 							
	 							handler: function(){
	 								this.close();
							    }, scope: this
							}
						 
						 
						 
                                                
                     ]
        	     }
        	     
        	     
        	    ]
        	}
        	
        	
        	
        	, {
        	    xtype: 'gridpanel',        		
        	    title: 'Distinta movimenti', flex: 50,
        	    
/*        	    
        	    features: [
        	               Ext.create('Ext.grid.feature.RowBody', {
        	                   getAdditionalData : function(data, rowIndex, record, orig) {
        	                       var headerCt = this.view.headerCt;
        	                       var colspan = headerCt.getColumnCount();
        	                       return {
        	                           rowBody : '<div style="padding-left: 130px;padding-top:5px"><b>Continent:</b> Some bla bla bla for record on row number ' + rowIndex + '</div>',
        	                           //rowBodyCls : (rowIndex % 2) ? 'bg-snow' : this.rowBodyCls,
        	                           rowBodyColspan : colspan
        	                       };
        	                   }
        	               })        
        	           ],
 */       	           
        	           
        	           
        	    
        	    tools: [{  
		                xtype: 'button',
		                text: 'Aggiungi <i class="fa fa-plus-circle"></i>',
						bind: {
							//visible: '{!is_handling_editable}'
					    	visible: '{is_handling_modify_can}'
						},						
						
		                handler: function(){	
		                	acs_show_win_std('Seleziona tipo dettaglio', myApp.railsBaseUri + 'terminal_movs/add_handling_items_select_type',
		                		 {rec_id: this.getViewModel().getData().rec.get('id')},
		                		 null, null, null, null, null, null, {mov_panel: this});
		                }, scope: this
		            }
                ],

        	    store: new Ext.data.Store({
        	    	autoLoad: false,
        	    	fields: [],
        	    	proxy: {
        	            type: 'ajax',
        	            url: myApp.railsBaseUri + 'handling_headers/hitems_sc_list',
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
        	       {text: 'Data/ora', width: 110, dataIndex: 'datetime_op', xtype:  'datecolumn', format: 'd/m/y H:i'},
        	       {text: 'Op', width: 160, dataIndex: 'handling_item_type_short', width: 100},
        	       {text: 'E/U', width: 40, dataIndex: 'handling_type', tooltip: 'Entrata / Uscita', tdCls: 'm-only-icon', renderer: pb_get_image_IO},
                   {text: 'P/V', width: 40, dataIndex: 'container_FE', tooltip: 'Pieno / Vuoto', tdCls: 'm-only-icon', renderer: pb_get_image_FE},
				   {text: 'Nave', width: 130, dataIndex: 'ship_id_Name', renderer: function(value, metaData, rec){
					   if (rec.get('handling_item_type') == 'FRCON'){
						   if (rec.get('datetime_op_end') === null)
							   return '(Ancora allacciato)';
						   else
							   return  ' -> ' + Ext.util.Format.date(rec.get('datetime_op_end'), 'd/m/y H:i');
					   }

					   if (rec.get('handling_item_type') == 'INSPECT'){
						   if (rec.get('lock_type') == 'DAMAGED')
							   return ' --> Danneggiato';
						   else
							   return  ' --> Buono';
					   }
					   
					   
					   return value; 
					}},
				   {text: 'Voy', width: 60, dataIndex: 'voyage'},
				   {text: 'Vettore', width: 130, dataIndex: 'carrier_id_Name'},                				                      				                      
				   {text: 'Autista', flex: 1, dataIndex: 'driver'},
				   {text: 'Sigillo', width: 80, dataIndex: 'seal'},
				   {text: 'Spediz.', width: 90, dataIndex: 'shipper_id_Name'},
				   {text: 'Terminal.', width: 90, dataIndex: 'terminal_id_Code'},
				   {header: 'Nt', dataIndex: 'notes', width: 40, renderer: pb_get_notes_icon},
				   {header: 'Lk', dataIndex: 'lock_type', width: 40, renderer: pb_get_image_lock},
				   {header: 'I', tooltip: 'Interchange', dataIndex: 'scan_file_file_size', width: 40, renderer: pb_get_interchange_icon},				   
        	       ]
                 
        	
	        	, listeners: {
	        		
	        		

					    celldblclick: function(gridView,htmlElement,columnIndex,rec, a, b, c, d, e, f){					    	
					    	
					        if (columnIndex == 12) { //doppio click su "notes"
                            	acs_show_win_std('Note dettaglio', myApp.railsBaseUri + 'handling_headers/hitems_edit_notes',
     			                		 {rec_id: rec.get('id')},
     			                		 600, 300, null, null, null, null, {mov_panel: gridView.up('panel').up('panel').up('panel')});
					        	
					        } //column notes
					        
					        if (columnIndex == 13) { //doppio click su lock type
					        	if (rec.get('lock_type') == 'DAMAGED' && myApp.canModifyHandling){
					        		acs_show_panel_std(myApp, myApp.railsBaseUri + 'repair_handling_items/rhi_edit', {handling_item_id: rec.get('id')}, 'Modifica');
					        	}
					        }
					        
					        if (columnIndex == 14) { //doppio click su interchange
					        	if (Ext.isEmpty(rec.get('scan_file_file_size')) || parseInt(rec.get('scan_file_file_size'))<=0) {
					        		acs_show_win_std('Allega scansione interchange', myApp.railsBaseUri + 'handling_headers/hi_attach_interchange', 
					        			{rec_id: rec.get('id')},
					        			600, 300, null, null, null, null, {mov_panel: gridView.up('panel').up('panel').up('panel')});
					        	} else {
					        		//mostro immagine
							     	   acs_show_win_std('Interchange', myApp.railsBaseUri + 'handling_headers/hi_attach_interchange_view_scan_file',
								     	 		{rec_id: rec.get('id')},
								     	 		800, 400, null, null, null, null, {mov_panel: gridView.up('panel').up('panel').up('panel')});										
					        		
					        	}
					        }					        
					    },
	        		
	        		
	        		
	        		
	                	itemcontextmenu : function(item, record, index, e, eOpts){
	                		eOpts.stopEvent();
                            var xy = eOpts.getXY();
                            
                            if (myApp.canModifyHandling == false)
                            	return false;
                            
                            ar_menu = [];
                            ar_menu.push(
                                {
                                   text : '<i class="fa fa-edit fa-1x"> Modifica</i>',                                                                                                        
                                   handler: function(){
                                   	
                                   	if (record.get('handling_item_type') == 'FRCON')
                                       	acs_show_win_std('Modifica dettaglio allaccio frigo', myApp.railsBaseUri + 'handling_headers/hitems_edit_rfcon',
                 			                		 {rec_id: record.get('id')},
                 			                		 600, 300, null, null, null, null, {mov_panel: item.up('panel').up('panel').up('panel')});
                                   		
                                   	else                                                     	
                                       	acs_show_win_std('Modifica dettaglio', myApp.railsBaseUri + 'handling_headers/hitems_edit_simple',
              			                		 {rec_id: record.get('id')},
              			                		 600, 400, null, null, null, null, {mov_panel: item.up('panel').up('panel').up('panel')});
                                   }
                                 }
                              );
                            
                            ar_menu.push(
                                {
                                      text : '<i class="fa fa-trash fa-1x"> Elimina</i>',                                                                                                        
                                      handler: function(){
                    					  Ext.MessageBox.confirm('Richieta conferma', 'Confermi eliminazione?', function(btn){
                    						   if(btn === 'yes'){
                                              	acs_show_win_std('Elimina dettaglio', myApp.railsBaseUri + 'handling_headers/hitem_delete_preview',
                     			                		 {rec_id: record.get('id')},
                     			                		 600, 400, null, null, null, null, {mov_panel: item.up('panel').up('panel').up('panel')});                                     							   
                    						   }
                    					  });
                                   	   
                                      }
                                 }
                             );
                            
                            
                            if (record.get('handling_item_type') == 'INSPECT'){
                                ar_menu.push(
                                        {
                                              text : '<i class="fa fa-trash fa-1x"> Converti in danneggiato (crea gestione preventivo) - No cambia stato</i>',                                                                                                        
                                              handler: function(){
                            					  Ext.MessageBox.confirm('Richieta conferma', 'Confermi creazione gestione preventivo?', function(btn){
                            						   if(btn === 'yes'){                                                      	         
                            							   
                            							   Ext.Ajax.request({
                            								url: myApp.railsBaseUri + 'handling_headers/hitem_convert_to_damaged',
               							                    waitMsg: 'Esecuzione in corso....',
               												method:'POST',                     
               							                    jsonData: {rec_id: record.get('id')},	
               							             	
               												success: function(result, request) {
               														var returnData = Ext.JSON.decode(result.responseText);
               														if (returnData.success == false){
               															Ext.MessageBox.show({
               										                        title: 'EXCEPTION',
               										                        msg: returnData.message,
               										                        icon: Ext.MessageBox.ERROR,
               										                        buttons: Ext.Msg.OK
               									                    	})
               									                      return false;										
               														}								
               												
               														console.log(item);
						 							
               												},
               												
               												failure: function(rec, op) {
               													var result = Ext.JSON.decode(op.getResponse().responseText);
               													Ext.MessageBox.show({
               								                        title: 'EXCEPTION',
               								                        msg: result.message,
               								                        icon: Ext.MessageBox.ERROR,
               								                        buttons: Ext.Msg.OK
               							                    	})					
               												}, scope: this,						
               																 
               									    	});	                                         							   
                            							   
                            						   } //if yes
                            					  });
                                           	   
                                              }
                                         }
                                     );
                            	
                            }
                            
                            
                            new Ext.menu.Menu({items: ar_menu}).showAt(xy); 	                	
	                }, scope: this
	            }        	
        	
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
