function Run_SSA_Sim(app)

% Stoichiometry
S = [-1,1,0,0,0,0,0;...% inf
     0,-1,1,0,0,0,0;...% infectious
     0,0,-1,1,0,0,0;...% sympt
     0,0,-1,0,0,1,0;...% recover
     0,0,0,-1,1,0,0;...% hospital
     0,0,0,-1,0,1,0;...% recover -no hospital
     0,0,0,0,-1,1,0;...% recover hospital
     0,0,0,-1,0,0,1;...% death 
     0,0,0,0,-1,0,1;]';% death 
  
 % initial Condition
 x0 = [app.S_0.Value;0;app.IU_0.Value;app.ID_0.Value;0;0;0];

 %Model parameters
 ki = 0.001;
 n_pre = app.d_pre.Value;
 n_post = app.d_post.Value;
 M = ceil(app.M_Hosp.Value*sum(x0)/10000);
 ks = 1/app.T_vis.Value;
 kinf = 1/app.t_i.Value;
 kr = 1/app.t_r.Value;
 knh = 1/app.t_r_nohosp.Value;
 kh = 1/app.t_r_hosp.Value;
 kd = app.P_d.Value*knh;
 
 % Propensity functions
 prop = @(x)[ki*x(1)*(n_pre*(x(3)/(n_pre+x(3)))+n_post*(x(4)/(n_post+x(4))));...
     kinf*x(2);...
     ks*x(3);...
     kr*x(3);...
     x(4)*(x(5)<M);...
     knh*x(4);...
     kh*x(5);...
     kd*x(4);...
     kd*x(5)]; 
 
 % Run ODE or SSA analysis
 TAarray = linspace(0,500,501);
 if app.ssa.Value % SSA
     [X_Array] = run_ssa(S,prop,x0,TAarray);
 else  % ODE
     fn = @(~,x)S*prop(x);
     [~,X_Array] = ode45(fn,TAarray,x0);
     X_Array = X_Array';
 end
  
 % Plot results.
 plot(app.ssa_results,TAarray,X_Array([2,3,4,5,7],:)/sum(x0),'linewidth',3);
 set(app.ssa_results,'ylim',[0,0.15])
 legend(app.ssa_results,{'nonifectuous','asymptomatic','symptomatic','hospitalized','deceased'});