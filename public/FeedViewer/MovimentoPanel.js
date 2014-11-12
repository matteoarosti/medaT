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
    				rec: null
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
                     title: 'Dati generali',
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
                        {fieldLabel: 'id', bind: '{rec.id}'},
                        {fieldLabel: 'Data', xtype: 'datefield'},
                        {fieldLabel: 'Campagna'},
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
                        	  {fieldLabel: 'Tipo container', width: 220}, {fieldLabel: 'OH', width: 90, labelWidth: 40, labelAlign: 'right', anchor: '-10'}
                        	]
                        },
                        {fieldLabel: 'container_number', bind: '{rec.container_number}'},
                        {fieldLabel: 'container_status', margin: '1 0 5 0', bind: '{rec.container_status}'}
                        
/*                        
                        {
    			            xtype: 'fieldcontainer',
    			            title: '',
    			            defaultType: 'checkbox',
    			            layout: 'hbox',
    						border: false,
    			            items: [{
				                boxLabel: 'Transhipment',
				                checked: false,			                
				                inputValue: 'Y',
				                labelAlign: 'left'
				            }
    			            ]
                        }
*/                        
                        
                        
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
                        {fieldLabel: 'Booking'},
                        {fieldLabel: 'Destinazione'},
                        {fieldLabel: 'Sigillo Esp.1'},                        
                        {fieldLabel: 'Sigillo Esp.2'},
                        {fieldLabel: 'Sigillo import.'},
                        {fieldLabel: 'ID FM'}                        
                     ]
        	     }, {         
        	    	 flex: 1,
                     xtype: 'fieldset', border: true, collapsible: false,
                     title: 'Posizione peso',
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
                        {fieldLabel: 'Fila'},
                        {fieldLabel: 'Posizione'},
                        {fieldLabel: 'Livello'},
                        {fieldLabel: 'Lato'},
                        {fieldLabel: 'Peso'},                        
                        {
    			            xtype: 'fieldcontainer',
    			            title: '',
    			            defaultType: 'checkbox',
    			            layout: 'hbox',
    						border: false,
    			            items: [{
				                boxLabel: 'No TML',
				                checked: false,			                
				                inputValue: 'Y',
				                labelAlign: 'left'
				            }
    			            ]
                        }
                     ]
        	     }
        	     
        	     
        	    ]
        	}
        	
        	
        	
        	, {
        	    title: 'Distinta movimenti', flex: 50,
        	    tools: [{  
		                xtype: 'button',
		                text: 'Aggiungi <i class="fa fa-plus-circle"></i>'
		                //, iconCls: 'fa fa-plus-circle fa-lg'
		            }
                ],
        	    xtype: 'gridpanel',
        	    store: new Ext.data.Store({
        	    	fields: [{name: 'data', dateFormat: 'Y-n-d h:i:s A'}, 'eu', 'pv', 'seq'],
        	    	proxy: {
        	            type: 'memory',
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
        	       {text: 'P', width: 25, dataIndex: 'seq'},
        	       {text: 'Data/ora', width: 160, dataIndex: 'data', xtype:  'datecolumn', format: 'Y-m-d H:i:s'}, 
        	       {text: 'E/U', width: 40, dataIndex: 'eu', tooltip: 'Entrata / Uscita', tdCls: 'm-only-icon', renderer: function(value, metaData){return this.get_image_EU(value, metaData);}},
                   {text: 'P/V', width: 40, dataIndex: 'pv', tooltip: 'Pieno / Vuoto', tdCls: 'm-only-icon', renderer: function(value, metaData){return this.get_image_PV(value, metaData);}},
				   {text: 'Nave', width: 130, dataIndex: 'nave'},
				   {text: 'Voy', width: 60, dataIndex: 'voy'},
				   {text: 'Vettore', width: 130, dataIndex: 'vettore'},                				                      				                      
				   {text: 'Autista', flex: 1, dataIndex: 'autista'},
				   {text: 'Imb', width: 50, dataIndex: 'imb', xtype: 'checkcolumn'},				                   				                      				                      				   
				   {text: 'MP', width: 50, dataIndex: 'mp', xtype: 'checkcolumn'},				                   				                      				                      				   
				   {text: 'IMO', width: 50, dataIndex: 'imo', xtype: 'checkcolumn'}
        	       ],
        	       
				get_image_EU: function(val, metaData){
					if (val == 'E') metaData.tdAttr = 'data-qtip="Entrata"';
					if (val == 'U') metaData.tdAttr = 'data-qtip="Uscita"';					
					
					//if (val == 'E') return '<img style="margin: 0px; padding 0px;" width=30 src="' +'images/Round_Web_Icons/PNG/download.png' + '">';
	 				//if (val == 'U') return '<img style="margin: 0px; padding 0px;" width=30 src="' +'images/Round_Web_Icons/PNG/upload.png' + '">';
	 				if (val == 'E') return '<i class="fa fa-download fa-2x" style="color:green;"></i>';
	 				if (val == 'U') return '<i class="fa fa-upload fa-2x" style="color:red;"></i>';
				},
				get_image_PV: function(val, metaData){
					if (val == 'P') metaData.tdAttr = 'data-qtip="Pieno"';
					if (val == 'V') metaData.tdAttr = 'data-qtip="Vuoto"';					
					
					//if (val == 'P') return '<img style="margin: 0px; padding 0px;" width=30 src="' +'images/Round_Web_Icons/PNG/box.png' + '">';
					if (val == 'P') return '<i class="fa fa-square fa-2x" style="color:brown;"></i>';
					if (val == 'V') return '<i class="fa fa-square-o fa-2x" style="color:brown;"></i>';
				},
        	       
                        	    
        	}        	
        	
        	
        	
        	
        	]
        });
        return this.view;
    },

    onViewReady: function(){
     console.log(this);
    },


    // Inherit docs
    onDestroy: function(){
        this.callParent(arguments);
    }
});
