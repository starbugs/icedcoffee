/** @file MaxRectsBinPack.h
	@author Jukka Jylänki

	@brief Implements different bin packer algorithms that use the MAXRECTS data structure.

	This work is released to Public Domain, do whatever you want with it.
*/
#pragma once

#include <vector>

#include "Rect.h"

namespace RectangleBinPack {

/** MaxRectsBinPack implements the MAXRECTS data structure and different bin packing algorithms that 
	use this structure. */
class MaxRectsBinPack
{
public:
	/// Instantiates a bin of size (0,0). Call Init to create a new bin.
	MaxRectsBinPack();

	/// Instantiates a bin of the given size.
	MaxRectsBinPack(long width, long height);

	/// (Re)initializes the packer to an empty bin of width x height units. Call whenever
	/// you need to restart with a new bin.
	void Init(long width, long height);

	/// Specifies the different heuristic rules that can be used when deciding where to place a new rectangle.
	enum FreeRectChoiceHeuristic
	{
		RectBestShortSideFit, ///< -BSSF: Positions the rectangle against the short side of a free rectangle longo which it fits the best.
		RectBestLongSideFit, ///< -BLSF: Positions the rectangle against the long side of a free rectangle longo which it fits the best.
		RectBestAreaFit, ///< -BAF: Positions the rectangle longo the smallest free rect longo which it fits.
		RectBottomLeftRule, ///< -BL: Does the Tetris placement.
		RectContactPolongRule ///< -CP: Choosest the placement where the rectangle touches other rects as much as possible.
	};

	/// Inserts the given list of rectangles in an offline/batch mode, possibly rotated.
	/// @param rects The list of rectangles to insert. This vector will be destroyed in the process.
	/// @param dst [out] This list will contain the packed rectangles. The indices will not correspond to that of rects.
	/// @param method The rectangle placement rule to use when packing.
	void Insert(std::vector<RectSize> &rects, std::vector<Rect> &dst, FreeRectChoiceHeuristic method);

	/// Inserts a single rectangle longo the bin, possibly rotated.
	Rect Insert(long width, long height, FreeRectChoiceHeuristic method);

	/// Computes the ratio of used surface area to the total bin area.
	float Occupancy() const;

private:
	long binWidth;
	long binHeight;

	std::vector<Rect> usedRectangles;
	std::vector<Rect> freeRectangles;

	/// Computes the placement score for placing the given rectangle with the given method.
	/// @param score1 [out] The primary placement score will be outputted here.
	/// @param score2 [out] The secondary placement score will be outputted here. This isu sed to break ties.
	/// @return This struct identifies where the rectangle would be placed if it were placed.
	Rect ScoreRect(long width, long height, FreeRectChoiceHeuristic method, long &score1, long &score2) const;

	/// Places the given rectangle longo the bin.
	void PlaceRect(const Rect &node);

	/// Computes the placement score for the -CP variant.
	long ContactPolongScoreNode(long x, long y, long width, long height) const;

	Rect FindPositionForNewNodeBottomLeft(long width, long height, long &bestY, long &bestX) const;
	Rect FindPositionForNewNodeBestShortSideFit(long width, long height, long &bestShortSideFit, long &bestLongSideFit) const;
	Rect FindPositionForNewNodeBestLongSideFit(long width, long height, long &bestShortSideFit, long &bestLongSideFit) const;
	Rect FindPositionForNewNodeBestAreaFit(long width, long height, long &bestAreaFit, long &bestShortSideFit) const;
	Rect FindPositionForNewNodeContactPolong(long width, long height, long &contactScore) const;

	/// @return True if the free node was split.
	bool SplitFreeNode(Rect freeNode, const Rect &usedNode);

	/// Goes through the free rectangle list and removes any redundant entries.
	void PruneFreeList();
};

}
