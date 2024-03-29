class World {
    ArrayList<Agent> agents = new ArrayList<Agent>();
    Food food; 
    int generation; 

    World(int numAgents, int numFood) {
        // Initialize food
        food = new Food(numFood);
         
        for (int i = 0; i < numAgents; i++) {
           PVector l = new PVector(random(width), random(height));
           agents.add(new Agent(l));
        }
        
        // Keep track of iterations.
        generation = 0; 
    }
    
    void run() {
      // Deal with food. 
      food.run(); 

      // Handle agents display, eating, reproduction
      for (int i = agents.size()-1; i >= 0; i--) {
        Agent a = agents.get(i);
        
        // Handle all the agent behavior. 
        // Seeking the food, steering, updating, and display
        a.run(food);
        
        // Health of the agent.
        if (a.dead()) { // Is it dead? 
          agents.remove(i); 
          food.add(a.position); // Make food where the organism died.
        }
        
        Agent child = a.reproduce(); 
        if (child != null) {
          agents.add(child);
        }
      }
      
      generation++; 
    }
}
