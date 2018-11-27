local
   % See project statement for API details.2
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then %exemple: a#3
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then %exemple: b
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then %exemple: a3
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         else 
            silence(duration:0)
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Les vérifications 
      %vérifie si le PartitionItem est une note 
      fun{IsANote PartitionItem} 
         case PartitionItem of nil then false
         [] {IsTuple PartitionItem} or {IsAtom PartitionItem} then true else false
         end
      end
         
      %vérifie si le PartitionItem est un accord(= à une liste de notes) 
      fun{IsAChord PartitionItem}
         case PartitionItem of nil then false
            [] {IsList PartitionItem}==true then true else false
         end
      end
      
      %vérifie si le PartitionItem est une transformation   
      fun{IsATransformation PartitionItem} 
         case {Label PartitionItem} of duration then true
            []stretch then true
            []drone then true
            []transpose then true
            else false
         end
      end
      
      %vérifie si le PartitionItem est une note extended ou un accord extended
      fun{NoteIsExtended PartitionItem}
            case {Label PartitionItem} 
            of silence andthen {Arity PartitionItem}.1==duration then true 
	         []note then true
	         else false
	         end
	   end
      
     fun{ChordIsExtended PartitionItem}
            case PartitionItem 
            of H|T andthen {NoteIsExtended H} then true
            else false   
            end
     end   
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin des vérifications   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcul durée transformations
         
      fun{TimeDuration Record}
         local X=Record in
            X.seconds
         end
      end
         
      fun{TimeStretch Record}   
         
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin durée transformations      
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fonctions des transformations    
      
      %change le temps d'une note soit d'un facteur "Factor" ou d'un temps "Time"
      fun{ChangeDuration Time Factor PartitionItem}
      end      
              
      %premiere transformation
      fun{Duration Record}
         local X=Record in
            Time = X.seconds
            L=X.1
            case L of nil then Record
            []H|T 
                     
                     
                     
          
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin des fonctions de transformation
                        
      %transforme un accord en un accord extended(= à une liste de notes extended)   
      fun{ChordToExtended Chord L} 
         case Chord of nil then {Reverse L}
         [] H|T and {IsANote H}==true then {ChordToExtended T {NoteToExtended H}|L}
         end
      end
                        
      %calcule la durée totale de la partition
      fun{TotalTime Partition Acc}
         case Partition of nil then Acc
	 []H|T and {IsANote H}==true andthen {NoteIsExtended H}==false then {TotalTime T Acc+1}
	 []H|T and {IsAChord H}==true andthen {ChordIsExtended H}==false then {TotalTime T Acc+1}
	 []H|T and {IsANote H}==true andthen {NoteIsExtended H}==true then local X=H in {TotalTime T Acc+X.duration} end
         []H|T and {IsAChord H}==true andthen {ChordIsExtended H}==true then local X=H.1 in {TotalTime T Acc+X.duration} end
         []H|T and {IsATransformation H}==true then
            case{Label H} of duration then {TimeDuration H}
            []stretch then
            []drone then
            []transpose then                  
         end
      end
                        
         
      %fonction qui prend en argument une Partition, (liste de Partition item) et qui retourne 1 liste, une contenant les notes et les accords extended    
      local fun{PartitionToTimedList2 Partition L}
            case Partition of nil then {Reverse L}
            []H|T and {IsANote H}==true then {PartitionToTimedList2 T L|{NoteToExtended H}}
            []H|T and {IsAChord H}==true then {PartitionToTimedList2 T L|{ChordToExtended H nil}}
            []H|T and {IsATransformation H}==true then
               case {Label H} of duration then
               []stretch then                  
               []drone then
               []transpose then
            end
         end
      in
         {PartitionToTimedList2 Partition nil}    
   end
                            
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile 'wave/animaux/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
