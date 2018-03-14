function g = multiplot(inputTable)


x = 1:size(inputTable,1);

vars_to_plot = inputTable.Properties.VariableNames;

     for my_vars = 1:length(vars_to_plot)
           
     g(my_vars, 1) = gramm('x', x, 'y', eval(strcat('inputTable.', vars_to_plot{my_vars})));
     g(my_vars,1).geom_line();
     
    
     end
     
g.draw()
    
end
