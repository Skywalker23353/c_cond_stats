function fields = load_BC_config_file_noz(C_one_bc_data,r_idx,z_idx)
    fields = {
        'Heatrelease',0.0,C_one_bc_data.HRR_mean(1:z_idx,r_idx),'$\dot{\omega}_{T}$';
    
        'Temperature',800,C_one_bc_data.T_mean(1:z_idx,r_idx),'$T$';
        
        'density',0.4243,C_one_bc_data.rho_mean(1:z_idx,r_idx),'$\rho$';
        
        'CH4',0.044,C_one_bc_data.CH4_mean(1:z_idx,r_idx),'$Y_{CH_4}$';
        
        'O2',0.222,C_one_bc_data.O2_mean(1:z_idx,r_idx),'$Y_{O_2}$';
        
        'CO2',0.0,C_one_bc_data.CO2_mean(1:z_idx,r_idx),'$Y_{CO_2}$';
        
        'H2O',0.0,C_one_bc_data.H2O_mean(1:z_idx,r_idx),'$Y_{H_2O}$';
    
%         'N2',0.732,0.732,'$Y_{N_2}$';
%     
%         'CH2O',0.0,0.00,'$Y_{CH_2O}$';
%     
%         'CH3',0.0,0.00,'$Y_{CH3}$';
%     
%         'CO',0.0,0.005007,'$Y_{CO}$';
    
        'H',0.0,0.000017284,'$Y_{H}$';
    
%         'H2',0.0,0.0001323,'$Y_{H2}$';
%     
%         'HO2',0.0,0.00000369,'$Y_{HO2}$';
%     
        'O',0.0,0.00066,'$Y_{O}$';
    
        'OH',0.0,0.004006,'$Y_{OH}$';

        'SYm_CH4',0.0,0.0,'$\dot{\omega}_{CH_4}$';
        
        'SYm_O2',0.0,0.0,'$\dot{\omega}_{O_2}$';
        
        'SYm_CO2',0.0,0.0,'$\dot{\omega}_{CO_2}$';
        
        'SYm_H2O',0.0,0.0,'$\dot{\omega}_{H_2O}$';
    
%         'SYm_CH2O',0.0,0.0,'$\dot{\omega}_{CH_2O}$';
%     
%         'SYm_CH3',0.0,0.0,'$\dot{\omega}_{CH3}$';
%     
%         'SYm_CO',0.0,0.0,'$\dot{\omega}_{CO}$';
%     
        'SYm_H',0.0,0.0,'$\dot{\omega}_{H}$';
    
%         'SYm_H2',0.0,0.0,'$\dot{\omega}_{H2}$';
%     
%         'SYm_HO2',0.0,0.0,'$\dot{\omega}_{HO2}$';
    
        'SYm_O',0.0,0.0,'$\dot{\omega}_{O}$';
    
        'SYm_OH',0.0,0.0,'$\dot{\omega}_{OH}$';

%         'SYm_N2',0.0,0.0,'$\dot{\omega}_{N_2}$';
    };
end