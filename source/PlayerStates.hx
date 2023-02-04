package;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxCamera;

/*
has most things that are duplicated for each player (strum groups, stats, cameras for downscroll, etc),
the strum group class has the rest of the stuff (notes, notesplash and strum notes)
*/
class PlayerStates
{
    public var Stats = {
		songScore : 0,
		scorelerp : 0,
        songHits : 0,
        accuracy : 0.0,
		acclerp : 0.0,
		curRank : "None",
		hitNoteAmount : 0.0,
        totalPlayed : 0,
		sustainsHit : 0,
        totalNotesHit : 0.0,
        totalNotes : 0,
        hitNotes : 0.0,
		marvelous : 0,
		sicks : 0,
		goods : 0,
		bads : 0,
		shits : 0,
		misses : 0,
		highestCombo : 0,
		combo : 0
	};

    public var playernum:Int;
    public function new(player:Int = 0)
    {
        playernum = player;
    }

    public function resetStats()
    {
        Stats.songScore = 0;
        Stats.scorelerp = 0;
		Stats.songHits = 0;
        Stats.accuracy = 0.0;
        Stats.acclerp = 0.0;
		Stats.curRank = "None";
		Stats.hitNoteAmount = 0.0;
        Stats.totalPlayed = 0;
		Stats.sustainsHit = 0;
        Stats.totalNotesHit = 0.0;
        Stats.totalNotes = 0;
        Stats.hitNotes = 0.0;
		Stats.marvelous = 0;
		Stats.sicks = 0;
		Stats.goods = 0;
		Stats.bads = 0;
		Stats.shits = 0;
		Stats.highestCombo = 0;
		Stats.combo = 0;
    }
}