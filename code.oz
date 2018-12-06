%COUCOUUUUUUUU!!
local
   % See project statement for API details.2
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      if {NoteIsExtended Note}==true then Note
      else
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
   end
   
   %transforme un accord en un accord extended(= à une liste de notes extended)   
   fun{ChordToExtended Chord } 
      case Chord of nil then Chord 
      []H|T then {NoteToExtended H}|{ChordToExtended T}
      end
    end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Les vérifications 
      %vérifie si le PartitionItem est une note 
   fun{IsANote PartitionItem} 
      if {IsAtom PartitionItem}==true then true
      elseif {IsList PartitionItem} then false
      else true
      end   
   end
         
      %vérifie si le PartitionItem est un accord(= à une liste de notes) 
   fun{IsAChord PartitionItem}
      case PartitionItem
      of nil then true
      []H|T andthen {IsANote H} then true
      else false  
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
        of H|T andthen {NoteIsExtended H}==true then true
        else false   
        end
      end
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin des vérifications   
   
			
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcul durée transformations
         
      fun{TimeDuration Records}
         local X=Records in
            X.seconds
         end
      end
         
      fun{TimeStretch Records}
      	{TotalTime Records.1 0}*Records.factor
      end				
				
      fun{TimeDrone Records}
         				
				
				
				
      fun{TimeExtendedNote Records}
      	case {Lable Records}
	of silence then 0
	[]note then Records.duration
	end					
      end
				
				
				
      fun{TimeExtendedChord L}
      	case L 
	of H|T then {TimeExtendedNote H}
	end
      end				
      
				
      	
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin durée transformations      
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fonctions des transformations    
      
      %change le temps d'une note soit d'un facteur "Factor" ou d'un temps "Time"
      fun{ChangeDuration Time Factor PartitionItem}
      end      
              
      %premiere transformation
      fun{Duration Records}
         Time=Records.seconds
         L=Records.1
         local fun{ChangeTimeDuration L Acc}
            case L of nil then Acc
	    []H|T then {ChangeTimeDuration T Acc+H.duration}      
            end
         end
         in
            {ChangeTimeDuration L 0}      
      end               
      
      fun{Stretch Records}
					Factor=Records.factor
					L=Records.1
					
          
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin des fonctions de transformation
                        
                        
      %calcule la durée totale de la partition
      fun{TotalTime Partition Acc}
         case Partition of nil then Acc
	 []H|T andthen {IsANote H}==true and {IsExtended H}==false then {TotalTime T Acc+1}
         []H|T and {IsAChord H}==true and {IsExtended H}==false then {TotalTime T Acc+1}
         []H|T and {IsANote H}==true and {IsExtended H}==true then local X=H in {TotalTime T Acc+X.duration} end
         []H|T and {IsAChord H}==true and {IsExtended H}==true then local X=H.1 in {TotalTime T Acc+X.duration} end
         []H|T and {IsATransformation H}==true then
            case{Label H} of duration then {TimeDuration H}
            []stretch then
            []drone then
            []transpose then                  
         end
      end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% prend une partition quelconque en input et revoie la partition etendue sans les transfo appliquees 				
     fun{ExtendedPartition Partition}
         case Partition of nil then Partition
         []H|T andthen {IsANote H}==true andthen {NoteIsExtended H}==false then {NoteToExtended H}|{ExtendedPartition T}
         []H|T andthen {IsAChord H}==true andthen {ChordIsExtended H}==false then {ChordToExtended H}|{ExtendedPartition T}
         []H|T andthen {NoteIsExtended H}==true then H|{ExtendedPartition T}
         []H|T andthen {ChordIsExtended H}==true then H|{ExtendedPartition T}
         []H|T andthen {IsATransformation H}==true then
	    case {Label H} 
	    of  duration then local X=H.1 in {ExtendedPartition X}|{ExtendedPartition T}end 
	    [] stretch then local Y=H.1 in {ExtendedPartition Y}|{ExtendedPartition T}end
	    [] drone then local Z=H.note in {ExtendedPartition Z}|{ExtendedPartition T}end
	    [] transpose then local S=H.1 in {ExtendedPartition S}|{ExtendedPartition T}end
	    end
         end
end

						
						
						
						
						
						
						
      %fonction qui prend en argument une Partition, (liste de Partition item) et qui retourne 1 liste, une contenant les notes et les accords extended    
   fun{PartitionToTImeList Partition}
   case Parition of nil then Parition
   []H|T andthen {IsANote H}==true then {Append {NoteToExtended H} {PartitionToTimeList T}}
   []H|T andthen {IsAChord H}==true then {Append {ChordToExtended H} {PartitionToTimeList T}}
   []H|T andthen {IsATransformation H}==true then
      case{Label H} of duration then {Append {Duration H} {PartitionToTimeList T}}
      []stretch then {Append {Stretch H} {PartitionToTimeList T}}
      []drone then {Append {Drone H} {PartitionToTimeList T}}
      []transpose then {Append {Transpose H} {PartitionToTimeList T}}
      end
   else
      {Append H {PartitionToTImeList T}}
   end
end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile 'wave/animaux/cow.wav'}
   end
   
						
						
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prend en argument une note et renvoie sa position par rapport a A4
						
   fun{Hauteur Note}					
						
   end	
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcule la fréquence d'une note grâce à sa hauteur
    fun{Frequence H}
	f = 2^(h/12) * 440 Hz	(juste pour se rappeler)					
	
							
    							
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
							
							
							
							
							
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
