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

Ext.define('FeedViewer.MenuPanel', {
    extend: 'Ext.panel.Panel',

    alias: 'widget.menupanel',

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
    	    	
    	this.store = Ext.create('Ext.data.TreeStore', {
    		fields: ['task', 'op'],
    	    proxy: {
    	        data : this.voci_menu,
    	        type: 'memory',
    	        reader: {
    	            type: 'json',
    	        }
    	    },
    	});
    	
    	
        this.view = Ext.create('Ext.tree.Panel', {
            store: this.store,
            rootVisible : false,
            columns: [{
                xtype: 'treecolumn',
                //text: 'Task',
                width: 200,
                sortable: true,
                dataIndex: 'task'
            }],
	        listeners: {
	            itemclick: function(s,r) {
	                    this.fireEvent('voce_menu_select', this, s, r);
	            }, scope: this
	        }
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
