// ---------------------------------------------------------------------
 	pb_get_image_IO = function(val, metaData){
		if (val == 'I') metaData.tdAttr = 'data-qtip="Entrata"';
		if (val == 'O') metaData.tdAttr = 'data-qtip="Uscita"';					
		
		if (val == 'I') return '<i class="fa fa-download fa-2x" style="color:green;"></i>';
		if (val == 'O') return '<i class="fa fa-upload fa-2x" style="color:red;"></i>';
	}
 	
 	
 	pb_get_image_in_terminal = function(val, metaData){
		if (val == true) return '<i class="fa fa-download fa-2x" style="color:green;"></i>';
		if (val == false) return '<i class="fa fa-upload fa-2x" style="color:red;"></i>';
	}
 	 	
 	 	
 	
	
	pb_get_image_FE = function(val, metaData){
		if (val == 'F') metaData.tdAttr = 'data-qtip="Pieno"';
		if (val == 'E') metaData.tdAttr = 'data-qtip="Vuoto"';					
		
		if (val == 'F') return '<i class="fa fa-square fa-2x" style="color:brown;"></i>';
		if (val == 'E') return '<i class="fa fa-square-o fa-2x" style="color:brown;"></i>';
	}



	pb_get_image_status = function(value, metaData, rec, rowIndex, colIndex, store) {
		if (value == 'OPEN') metaData.tdAttr = 'data-qtip="Open"';
		if (value == 'CLOSE') metaData.tdAttr = 'data-qtip="Close"';					
		if (value == 'NEW') metaData.tdAttr = 'data-qtip="New"';
		
		if (value == 'OPEN') return '<i class="fa fa-circle-o fa-2x" style="color:green;"></i>';
		if (value == 'CLOSE') return '<i class="fa fa-times fa-2x" style="color:gray;"></i>';
		if (value == 'NEW') return '<i class="fa fa-plus fa-2x" style="color:red;"></i>';
		return value;
	}
	
	pb_get_image_lock = function(value, metaData, rec, rowIndex, colIndex, store) {
		if (value == 'INSPECT') metaData.tdAttr = 'data-qtip="Da ispezionare"';
		if (value == 'DAMAGED') metaData.tdAttr = 'data-qtip="Danneggiato"';					
		
		if (value == 'INSPECT') return '<i class="fa fa-search fa-2x" style="color:red;"></i>';
		if (value == 'DAMAGED') return '<i class="fa fa-warning fa-2x" style="color:red;"></i>';
		return value;
	}

	pb_get_notes_icon = function(value, metaData, rec, rowIndex, colIndex, store) {
		if (Ext.isEmpty(rec.get('notes')) && Ext.isEmpty(rec.get('notes_int')))
			return '<i class="fa fa-square-o fa-2x" style="color:transparent;"></i>';
		//segnalo presenza note			
		return '<i class="fa fa-file-text-o fa-2x" style="color:red;"></i>';
		
	}
	
	
// ----------------------------------------
function acs_show_panel_std(app, url, jsonData, tab_id, listeners, loadBodyMask){
	
	
	if(typeof(listeners)==='undefined' || listeners==null) listeners = {};		
	
	if (loadBodyMask == 'Y')
		Ext.getBody().mask('Loading... ', 'loading').show();	
	

	if (app.xtype == 'tabpanel')
		mp = app;
	else
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
	if(typeof(iconCls)==='undefined'  || iconCls==null) iconCls = 'fa fa-th-large';	
	
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
