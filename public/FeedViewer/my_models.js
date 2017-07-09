Ext.define("Porto", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: root_path + 'terminal_movs/sc_read',
            create: root_path + 'terminal_movs/sc_create',
            update: root_path + 'terminal_movs/sc_update',
            destroy: root_path + 'terminal_movs/sc_destroy'
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
            read: root_path + 'shipowners/sc_read',
            create: root_path + 'shipowners/sc_create',
            update: root_path + 'shipowners/sc_update',
            destroy: root_path + 'shipowners/sc_destroy'
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
            read: root_path + 'carriers/sc_read',
            create: root_path + 'carriers/sc_create',
            update: root_path + 'carriers/sc_update',
            destroy: root_path + 'carriers/sc_destroy'
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
            read: root_path + 'equipment/sc_read',
            create: root_path + 'equipment/sc_create',
            update: root_path + 'equipment/sc_update',
            destroy: root_path + 'equipment/sc_destroy'
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
            read: root_path + 'iso_equipment/sc_read',
            create: root_path + 'iso_equipment/sc_create',
            update: root_path + 'iso_equipment/sc_update',
            destroy: root_path + 'iso_equipment/sc_destroy'
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
            read: root_path + 'ports/sc_read',
            create: root_path + 'ports/sc_create',
            update: root_path + 'ports/sc_update',
            destroy: root_path + 'ports/sc_destroy'
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
            read: root_path + 'ships/sc_read',
            create: root_path + 'ships/sc_create',
            update: root_path + 'ships/sc_update',
            destroy: root_path + 'ships/sc_destroy'
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
            read: root_path + 'shippers/sc_read',
            create: root_path + 'shippers/sc_create',
            update: root_path + 'shippers/sc_update',
            destroy: root_path + 'shippers/sc_destroy'
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
            read: root_path + 'handling_headers/sc_read',
            create: root_path + 'handling_headers/sc_create',
            update: root_path + 'handling_headers/sc_update',
            destroy: root_path + 'handling_headers/extjs_sc_destroy'
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
            read: root_path + 'handling_headers/hitems_sc_read',
            create: root_path + 'handling_headers/hitems_sc_create',
            update: root_path + 'handling_headers/hitems_sc_update',
            destroy: root_path + 'handling_headers/hitems_sc_destroy'
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
            read: root_path + 'user_managers/hitems_sc_read',
            create: root_path + 'user_managers/hitems_sc_create',
            update: root_path + 'user_managers/hitems_sc_update',
            destroy: root_path + 'user_managers/hitems_sc_destroy'
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
            read: root_path + 'import_headers/sc_read',
            create: root_path + 'import_headers/sc_create',
            update: root_path + 'import_headers/sc_update',
            destroy: root_path + 'import_headers/sc_destroy'
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
            read: root_path + 'bookings/sc_read',
            create: root_path + 'bookings/sc_create',
            update: root_path + 'bookings/sc_update',
            destroy: root_path + 'bookings/extjs_sc_destroy'
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
Ext.define("BookingItem", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: root_path + 'bookings/bitems_sc_read',
            create: root_path + 'bookings/bitems_sc_create',
            update: root_path + 'bookings/bitems_sc_update',
            destroy: root_path + 'bookings/bitems_sc_destroy'
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
Ext.define("Terminal", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: root_path + 'terminals/sc_read',
            create: root_path + 'terminals/sc_create',
            update: root_path + 'terminals/sc_update',
            destroy: root_path + 'terminals/sc_destroy'
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
Ext.define("RepairPosition", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: root_path + 'repair_positions/sc_read',
            create: root_path + 'repair_positions/sc_create',
            update: root_path + 'repair_positions/sc_update',
            destroy: root_path + 'repair_positions/sc_destroy'
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
Ext.define("RepairComponent", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: root_path + 'repair_components/sc_read',
            create: root_path + 'repair_components/sc_create',
            update: root_path + 'repair_components/sc_update',
            destroy: root_path + 'repair_components/sc_destroy'
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
Ext.define("RepairProcessing", { extend: "Ext.data.Model",
    fields: [],
    proxy: {
        type: 'ajax',
        api: {
            read: root_path + 'repair_processings/sc_read',
            create: root_path + 'repair_processings/sc_create',
            update: root_path + 'repair_processings/sc_update',
            destroy: root_path + 'repair_processings/sc_destroy'
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
Ext.define("RepairPrice", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'repair_prices/sc_read',
            create: root_path + 'repair_prices/sc_create',
            update: root_path + 'repair_prices/sc_update',
            destroy: root_path + 'repair_prices/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("ToDoItem", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'to_do_items/sc_read',
            create: root_path + 'to_do_items/sc_create',
            update: root_path + 'to_do_items/sc_update',
            destroy: root_path + 'to_do_items/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("Pier", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'piers/sc_read',
            create: root_path + 'piers/sc_create',
            update: root_path + 'piers/sc_update',
            destroy: root_path + 'piers/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("Customer", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'customers/sc_read',
            create: root_path + 'customers/sc_create',
            update: root_path + 'customers/sc_update',
            destroy: root_path + 'customers/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("ShipPrepareOp", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'ship_prepare_ops/sc_read',
            create: root_path + 'ship_prepare_ops/sc_create',
            update: root_path + 'ship_prepare_ops/sc_update',
            destroy: root_path + 'ship_prepare_ops/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("Um", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'ums/sc_read',
            create: root_path + 'ums/sc_create',
            update: root_path + 'ums/sc_update',
            destroy: root_path + 'ums/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("ActivityOp", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'activity_ops/sc_read',
            create: root_path + 'activity_ops/sc_create',
            update: root_path + 'activity_ops/sc_update',
            destroy: root_path + 'activity_ops/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
Ext.define("Gru", { extend: "Ext.data.Model",
    fields: [],    
    proxy: {
        type: 'ajax',
        
        method: 'POST',
        
		//Add these two properties
		actionMethods: {
			read: 'POST'
		},
        
        api: {
            read: root_path + 'grus/sc_read',
            create: root_path + 'grus/sc_create',
            update: root_path + 'grus/sc_update',
            destroy: root_path + 'grus/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message',
            method: 'POST'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        }
    }
});
