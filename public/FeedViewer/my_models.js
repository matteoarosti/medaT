Ext.define("Porto", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/terminal_movs/sc_read',
            create: '/medaT/' + '/terminal_movs/sc_create',
            update: '/medaT/' + '/terminal_movs/sc_update',
            destroy: '/medaT/' + '/terminal_movs/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        },        
    },
	validations: [
	        //{type: 'presence',  field: 'age'},
	        //{type: 'length',    field: 'denominazione',     min: 6},
	        //{type: 'inclusion', field: 'gender',   list: ['Male', 'Female']},
	        //{type: 'exclusion', field: 'username', list: ['Admin', 'Operator']},
	        //{type: 'format',    field: 'username', matcher: /([a-z]+)[0-9]{2,3}/}
	    ]    
});


Ext.define("Shipowner", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/shipowners/sc_read',
            create: '/medaT/' + '/shipowners/sc_create',
            update: '/medaT/' + '/shipowners/sc_update',
            destroy: '/medaT/' + '/shipowners/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data',
            getRecordData: function (record)
        		{
        			console.log('getRecordData');
          			return { 'data': Ext.JSON.encode(record.data) };
        		}
        },        
    }    
});


Ext.define("Carrier", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/carriers/sc_read',
            create: '/medaT/' + '/carriers/sc_create',
            update: '/medaT/' + '/carriers/sc_update',
            destroy: '/medaT/' + '/carriers/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data',
            getRecordData: function (record)
        		{
        			console.log('getRecordData');
          			return { 'data': Ext.JSON.encode(record.data) };
        		}
        },        
    }    
});

Ext.define("Equipment", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/equipment/sc_read',
            create: '/medaT/' + '/equipment/sc_create',
            update: '/medaT/' + '/equipment/sc_update',
            destroy: '/medaT/' + '/equipment/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});


Ext.define("IsoEquipment", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/iso_equipment/sc_read',
            create: '/medaT/' + '/iso_equipment/sc_create',
            update: '/medaT/' + '/iso_equipment/sc_update',
            destroy: '/medaT/' + '/iso_equipment/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});


Ext.define("Port", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/ports/sc_read',
            create: '/medaT/' + '/ports/sc_create',
            update: '/medaT/' + '/ports/sc_update',
            destroy: '/medaT/' + '/ports/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});

Ext.define("Ship", { extend: "Ext.data.Model",
	reference: 'Shipowner',
    fields: [
    	//{name: 'shipowner_id_Name', mapping: 'shipowner.name'},
    	//{name: 'shipowner_id_Name', convert: function(value, rec){console.log(value); console.log(rec); return rec.data.shipowner.name;}}
    ],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/ships/sc_read',
            create: '/medaT/' + '/ships/sc_create',
            update: '/medaT/' + '/ships/sc_update',
            destroy: '/medaT/' + '/ships/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});

Ext.define("Shipper", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/shippers/sc_read',
            create: '/medaT/' + '/shippers/sc_create',
            update: '/medaT/' + '/shippers/sc_update',
            destroy: '/medaT/' + '/shippers/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});

Ext.define("HandlingHeader", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/handling_headers/sc_read',
            create: '/medaT/' + '/handling_headers/sc_create',
            update: '/medaT/' + '/handling_headers/sc_update',
            destroy: '/medaT/' + '/handling_headers/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            rootProperty: 'data'            
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});
Ext.define("HandlingItem", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/medaT/' + '/handling_headers/hitems_sc_read',
            create: '/medaT/' + '/handling_headers/hitems_sc_create',
            update: '/medaT/' + '/handling_headers/hitems_sc_update',
            destroy: '/medaT/' + '/handling_headers/hitems_sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }        
    }    
});
Ext.define("User", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: '/medaT/' + '/user_managers/hitems_sc_read',
            create: '/medaT/' + '/user_managers/hitems_sc_create',
            update: '/medaT/' + '/user_managers/hitems_sc_update',
            destroy: '/medaT/' + '/user_managers/hitems_sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("ImportHeader", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: '/medaT/' + '/import_header/hitems_sc_read',
            create: '/medaT/' + '/import_header/hitems_sc_create',
            update: '/medaT/' + '/import_header/hitems_sc_update',
            destroy: '/medaT/' + '/import_header/hitems_sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("Booking", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: '/medaT/' + '/bookings/sc_read',
            create: '/medaT/' + '/bookings/sc_create',
            update: '/medaT/' + '/bookings/sc_update',
            destroy: '/medaT/' + '/bookings/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});