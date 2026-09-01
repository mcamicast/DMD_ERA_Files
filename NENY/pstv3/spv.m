function [bus_new] = spv(i,k,bus,flag,busi_v)
% Syntax: [bus_new] = wtg(i,k,bus,flag,busi_v)
% 07/08/2012
% Purpose: Solar PV model (utility scale)
% Model only has vectorized computation
%
% NOTE - static var bus must be declared as a non-conforming load bus.
%
% Input: i - static var number
%            if i= 0, vectorized computation
%        k - integer time
%        bus - solved loadflow bus data
%        flag - 0 - initialization
%               1 - network interface computation
%               2 - generator dynamics computation
%        v_sbus - svc bus voltage


% system variables
global  basmva bus_int bus_freq

% Solar Power Plant (spv) Variables
