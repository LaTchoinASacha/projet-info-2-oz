local
   % See project statement for API details.2
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
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
         [] {IsList PartitionItem}==true then true else false %peut être pas mettre de case et juste {IsList PartitionItem}, plus rapide?
         end
      end
      
      %vérifie si le PartitionItem est une transformation   
      fun{IsATransformation PartitionItem} 
         case PartitionItem of nil then false
         [] {IsRecord PartitionItem}==true then true else false %peut être pas mettre de case et juste {IsRecord PartitionItem}, plus rapide?
         end
      end
      
      %vérifie si c'est une durée
      fun{IsADuration Duration}
         case Duration of nil then false
         [] {IsList Duration} == true then true
         end
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
         
      %transforme un accord en un accord extended(= à une liste de notes extended)   
      fun{ChordToExtended Chord L} 
         case Chord of nil then {Reverse L}
         [] H|T and {IsANote H}==true then {ChordToExtended T {NoteToExtended H}|L}
         end
      end
      
      %calcule le nombre de notes et d'accords d'une partition
      fun{Count Partition Acc}
         case Partion of nil then Acc
         [] H|T then {Count T Acc+1}
         end
      end
      
      %change le temps d'une note soit d'un facteur "Factor" ou d'un temps "Time"
      fun{Change Time Factor PartitionItem}
            if {IsANote PartitionItem}==true and Time >0 then
               note(name:Name octave:Octave sharp:true duration:Time instrument:none)
            elseif {IsANote PartitionItem}==true and Factor >0 then
               note(name:Name octave:Octave sharp:true duration:1*Factor instrument:none)
            elseif {IsAChord PartitionItem}==true and Time >0 then
         
         
      %premiere transformation
      fun{Duration Time Partition1 Partition2}
         local N={Count Partition1 0} in
            case Partition1 of nil then {Reverse Partition2}
               []H|T and {IsANote}==true then {Duration T {Change (Time/N) 0 H}|Partition2}
               []H|T and {IsAChord}==true then {Duration T {Change (Time/N) 0 H}|Partition2}       
               
      %fonction qui prend en argument une Partition, (liste de Partition item) et qui retourne 2 listes, une contenant les notes (L1) et l'autre contenant les accords (L2)    
      local fun{PartitionToTimedList2 Partition L}
            case Partition of nil then {Reverse L}
            [] H|T and {IsANote H}==true then {PartitionToTimedList2 T L|{NoteToExtended H}}
            [] H|T and {IsAChord H}==true then {PartitionToTimedList2 T L|{ChordToExtended H nil}}
            [] H|T and {IsATransformation H}==true then
                  case H of nil then nil %je savais pas quoi mettre dans le premier case mais ça doit pas être nil
                        [] H|T and {IsADuration H}
            [] H|T and {IsANote H}==false and {IsAChord H}==false and {IsATransformation H}==false then {PartitionToTimedList2 T L1 L2}
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
