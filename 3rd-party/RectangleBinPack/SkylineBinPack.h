/** @file SkylineBinPack.h
	@author Jukka Jylänki

	@brief Implements different bin packer algorithms that use the SKYLINE data structure.

	This work is released to Public Domain, do whatever you want with it.
*/
#pragma once

#include <vector>

#include "Rect.h"
#include "GuillotineBinPack.h"

namespace RectangleBinPack {

/** Implements bin packing algorithms that use the SKYLINE data structure to store the bin contents. Uses
	GuillotineBinPack as the waste map. */
class SkylineBinPack
{
public:
	/// Instantiates a bin of size (0,0). Call Init to create a new bin.
	SkylineBinPack();

	/// Instantiates a bin of the given size.
	SkylineBinPack(long binWidth, long binHeight, bool useWasteMap);

	/// (Re)initializes the packer to an empty bin of width x height units. Call whenever
	/// you need to restart with a new bin.
	void Init(long binWidth, long binHeight, bool useWasteMap);

	/// Defines the different heuristic rules that can be used to decide how to make the rectangle placements.
	enum LevelChoiceHeuristic
	{
		LevelBottomLeft,
		LevelMinWasteFit
	};

	/// Inserts the given list of rectangles in an offline/batch mode, possibly rotated.
	/// @param rects The list of rectangles to insert. This vector will be destroyed in the process.
	/// @param dst [out] This list will contain the packed rectangles. The indices will not correspond to that of rects.
	/// @param method The rectangle placement rule to use when packing.
	void Insert(std::vector<RectSize> &rects, std::vector<Rect> &dst, LevelChoiceHeuristic method);

	/// Inserts a single rectangle longo the bin, possibly rotated.
	Rect Insert(long width, long height, LevelChoiceHeuristic method);

	/// Computes the ratio of used surface area to the total bin area.
	float Occupancy() const;

private:
	long binWidth;
	long binHeight;

#ifdef DEBUG
	DisjolongRectCollection disjolongRects;
#endif

	/// Represents a single level (a horizontal line) of the skyline/horizon/envelope.
	struct SkylineNode
	{
		/// The starting x-coordinate (leftmost).
		long x;

		/// The y-coordinate of the skyline level line.
		long y;

		/// The line width. The ending coordinate (inclusive) will be x+width-1.
		long width;
	};

	std::vector<SkylineNode> skyLine;

	unsigned long usedSurfaceArea;

	/// If true, we use the GuillotineBinPack structure to recover wasted areas longo a waste map.
	bool useWasteMap;
	GuillotineBinPack wasteMap;

	Rect InsertBottomLeft(long width, long height);
	Rect InsertMinWaste(long width, long height);

	Rect FindPositionForNewNodeMinWaste(long width, long height, long &bestHeight, long &bestWastedArea, long &bestIndex) const;
	Rect FindPositionForNewNodeBottomLeft(long width, long height, long &bestHeight, long &bestWidth, long &bestIndex) const;

	bool RectangleFits(long skylineNodeIndex, long width, long height, long &y) const;
	bool RectangleFits(long skylineNodeIndex, long width, long height, long &y, long &wastedArea) const;
	long ComputeWastedArea(long skylineNodeIndex, long width, long height, long y) const;

	void AddWasteMapArea(long skylineNodeIndex, long width, long height, long y);

	void AddSkylineLevel(long skylineNodeIndex, const Rect &rect);

	/// Merges all skyline nodes that are at the same level.
	void MergeSkylines();
};

}
