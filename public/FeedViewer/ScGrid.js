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

Ext.define('FeedViewer.ScGrid', {
    extend: 'Ext.panel.Panel',

    alias: 'widget.sc_grid',

    animCollapse: true,
    layout: 'fit',
    title: 'Menu',
    
    

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
        });
        this.callParent(arguments);
    },

    /**
     * Create the DataView to be used for the feed list.
     * @private
     * @return {Ext.view.View}
     */
    createView: function(){    	    	
    	    
        this.view = Ext.create('Ext.grid.Panel', {
            store: this.store,
            columns: this.columns,
            publishes: ['mRecord'],
            
			columnLines: false,
			stripeRows: true,   
			multiSelect: true,         
            
            bind: '{customers}',
            reference: 'customerGrid',
            requires: ['Ext.grid.plugin.CellEditing'],
            plugins: [{
            	ptype: 'cellediting',
            	clicksToEdit: 3,
            	pluginId: 'cellediting'
            }],
            
			viewConfig: {
			        getRowClass: function(record, index, rowParams, store) {
			            return (index % 2 == 0) ? '' : 'row-alt';
			        }
			    },            
            
            listeners : {
                itemdblclick: function(dv, record, item, index, e) {                	
                	newPanel = this.createEditView(record);                	
                	newPanel.getViewModel().setData({rec: record});
                    myApp.feedInfo.add(newPanel).show();
                }, scope: this
            }, 
            
			dockedItems: [{
			    xtype: 'toolbar',
			    dock: 'right',
			    width: 135,
				defaults: {
			        xtype: 'button', scale: 'medium', textAlign: 'left'
                },			    
			    margin: '40 10 10 10',
			    items: [
			    	{text: 'Crea nuovo', iconCls: 'fa fa-plus fa-2x', cls: 'btn-add', handler: function(){
			    		new_rec = Ext.create(this.down('grid').getStore().model.entityName, {});
			    		new_rec.set('id', null);
			    		this.down('grid').getStore().insert(0, new_rec);
                		newPanel = this.createEditView();
                		newPanel.getViewModel().setData({rec: new_rec});
                    	myApp.feedInfo.add(newPanel).show();			    			
			    		}, scope: this
			    	},
			    	{text: 'Modifica', iconCls: 'fa fa-edit fa-2x', handler: function(){			    	
                		newPanel = this.createEditView();
                		newPanel.getViewModel().setData({rec: this.down('grid').getView().getSelectionModel().getSelection()[0]});
                    	myApp.feedInfo.add(newPanel).show();			    			
			    		}, scope: this
			    	},
			    	{text: 'Visualizza', iconCls: 'fa fa-search fa-2x', handler: function(){			    	
                		newPanel = this.createEditView();
                		newPanel.getViewModel().setData({rec: this.down('grid').getView().getSelectionModel().getSelection()[0]});
                    	myApp.feedInfo.add(newPanel).show();			    			
			    		}, scope: this},
			    	{text: 'Duplica', iconCls: 'fa fa-files-o fa-2x', handler: function(){
			    		new_rec = Ext.create(this.down('grid').getStore().model.entityName, {});
			    		new_rec.set(this.down('grid').getView().getSelectionModel().getSelection()[0].data);
			    		new_rec.set('id', null);
			    		this.down('grid').getStore().insert(0, new_rec);
                		newPanel = this.createEditView();
                		newPanel.getViewModel().setData({rec: new_rec});
                    	myApp.feedInfo.add(newPanel).show();			    			
			    		}, scope: this},
			    	
					{xtype: 'tbfill'}, 
					{text: 'Elimina', iconCls: 'fa fa-trash fa-2x', cls: 'btn-del',
						handler: function(a,b,c,d){
								grid = this.up('grid');
			                    var selection = grid.getView().getSelectionModel().getSelection();
			                    if (selection) {
			                        if(selection.length>0) {
						                    grid.getStore().remove(selection);
						                    grid.getStore().sync();
						            }
			                    }
			                }					
					}
				]
			}]                       
        });        
        
        return this.view;
    },
    
    createEditView: function(rec){
    	return Ext.create('Ext.form.Panel', {
    		//title: this.model_name + ' #' + parseInt(rec.id),
    		title: this.model_name,
    		layout: 'form',
    		closable: true,
    		defaultType: 'textfield',
    		viewModel: {
    			data: {
    				rec: null
    			}
    		},
    		items: this.form_fields,
    		tbar: [{
    			text: 'Salva e chiudi', cls: 'btn-confirm', scale: 'medium',
    			handler: function(){    				
    				form = this.up('form').getForm();
    				panel = this.up('panel');
    				rec = this.up('form').getViewModel().getData().rec;
    				 if (form.isValid()) { 
    					 rec.save({
							success: function(rec, op) {
							//aggiorno il recordset con il record ritornato dal server (per id, updated_at...)
							var result = Ext.JSON.decode(op.getResponse().responseText);
							rec.set(result.data[0]);	
							},
    					 
    					 });
    					 panel.close();
    				 }
    			}
    		}, {xtype: 'tbfill'}, {
    			text: 'Elimina', cls: 'btn-del', scale: 'medium',
    			handler: function(){    				
    				form = this.up('form').getForm();
    				panel = this.up('panel');
    				grid = this.up('grid');
    				rec = this.up('form').getViewModel().getData().rec;
    				 if (form.isValid()) { 
    					 grid.getStore().remove(rec);
    					 panel.close();
    				 }
    			}
    		}	
    		]

    	});
    },

    onViewReady: function(){
    },


    // Inherit docs
    onDestroy: function(){
        this.callParent(arguments);
    }
});
