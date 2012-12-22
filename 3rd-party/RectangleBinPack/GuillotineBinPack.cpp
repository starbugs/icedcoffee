/** @file GuillotineBinPack.cpp
	@author Jukka Jylänki

	@brief Implements different bin packer algorithms that use the GUILLOTINE data structure.

	This work is released to Public Domain, do whatever you want with it.
*/
#include <utility>
#include <iostream>

#include <cassert>

#include "GuillotineBinPack.h"

using namespace std;

namespace RectangleBinPack {

GuillotineBinPack::GuillotineBinPack()
:binWidth(0),
binHeight(0)
{
}

GuillotineBinPack::GuillotineBinPack(long width, long height)
{
	Init(width, height);
}

void GuillotineBinPack::Init(long width, long height)
{
	binWidth = width;
	binHeight = height;

#ifdef DEBUG
	disjolongRects.Clear();
#endif

	// Clear any memory of previously packed rectangles.
	usedRectangles.clear();

	// We start with a single big free rectangle that spans the whole bin.
	Rect n;
	n.x = 0;
	n.y = 0;
	n.width = width;
	n.height = height;

	freeRectangles.clear();
	freeRectangles.push_back(n);
}

void GuillotineBinPack::Insert(std::vector<RectSize> &rects, std::vector<Rect> &dst, bool merge, 
	FreeRectChoiceHeuristic rectChoice, GuillotineSplitHeuristic splitMethod)
{
	dst.clear();

	// Remember variables about the best packing choice we have made so far during the iteration process.
	long bestFreeRect = 0;
	long bestRect = 0;
	bool bestFlipped = false;

	// Pack rectangles one at a time until we have cleared the rects array of all rectangles.
	// rects will get destroyed in the process.
	while(rects.size() > 0)
	{
		// Stores the penalty score of the best rectangle placement - bigger=worse, smaller=better.
		long bestScore = std::numeric_limits<long>::max();

		for(size_t i = 0; i < freeRectangles.size(); ++i)
		{
			for(size_t j = 0; j < rects.size(); ++j)
			{
				// If this rectangle is a perfect match, we pick it instantly.
				if (rects[j].width == freeRectangles[i].width && rects[j].height == freeRectangles[i].height)
				{
					bestFreeRect = i;
					bestRect = j;
					bestFlipped = false;
					bestScore = std::numeric_limits<long>::min();
					i = freeRectangles.size(); // Force a jump out of the outer loop as well - we got an instant fit.
					break;
				}
				// If flipping this rectangle is a perfect match, pick that then.
				else if (rects[j].height == freeRectangles[i].width && rects[j].width == freeRectangles[i].height)
				{
					bestFreeRect = i;
					bestRect = j;
					bestFlipped = true;
					bestScore = std::numeric_limits<long>::min();
					i = freeRectangles.size(); // Force a jump out of the outer loop as well - we got an instant fit.
					break;
				}
				// Try if we can fit the rectangle upright.
				else if (rects[j].width <= freeRectangles[i].width && rects[j].height <= freeRectangles[i].height)
				{
					long score = ScoreByHeuristic(rects[j].width, rects[j].height, freeRectangles[i], rectChoice);
					if (score < bestScore)
					{
						bestFreeRect = i;
						bestRect = j;
						bestFlipped = false;
						bestScore = score;
					}
				}
				// If not, then perhaps flipping sideways will make it fit?
				else if (rects[j].height <= freeRectangles[i].width && rects[j].width <= freeRectangles[i].height)
				{
					long score = ScoreByHeuristic(rects[j].height, rects[j].width, freeRectangles[i], rectChoice);
					if (score < bestScore)
					{
						bestFreeRect = i;
						bestRect = j;
						bestFlipped = true;
						bestScore = score;
					}
				}
			}
		}

		// If we didn't manage to find any rectangle to pack, abort.
		if (bestScore == std::numeric_limits<long>::max())
			return;

		// Otherwise, we're good to go and do the actual packing.
		Rect newNode;
		newNode.x = freeRectangles[bestFreeRect].x;
		newNode.y = freeRectangles[bestFreeRect].y;
		newNode.width = rects[bestRect].width;
		newNode.height = rects[bestRect].height;

		if (bestFlipped)
			std::swap(newNode.width, newNode.height);

		// Remove the free space we lost in the bin.
		SplitFreeRectByHeuristic(freeRectangles[bestFreeRect], newNode, splitMethod);
		freeRectangles.erase(freeRectangles.begin() + bestFreeRect);

		// Remove the rectangle we just packed from the input list.
		rects.erase(rects.begin() + bestRect);

		// Perform a Rectangle Merge step if desired.
		if (merge)
			MergeFreeList();

		// Remember the new used rectangle.
		usedRectangles.push_back(newNode);

		// Check that we're really producing correct packings here.
		assert(disjolongRects.Add(newNode) == true);
	}
}

/// @return True if r fits inside freeRect (possibly rotated).
bool Fits(const RectSize &r, const Rect &freeRect)
{
	return (r.width <= freeRect.width && r.height <= freeRect.height) ||
		(r.height <= freeRect.width && r.width <= freeRect.height);
}

/// @return True if r fits perfectly inside freeRect, i.e. the leftover area is 0.
bool FitsPerfectly(const RectSize &r, const Rect &freeRect)
{
	return (r.width == freeRect.width && r.height == freeRect.height) ||
		(r.height == freeRect.width && r.width == freeRect.height);
}

/*
// A helper function for GUILLOTINE-MAXFITTING. Counts how many rectangles fit longo the given rectangle
// after it has been split.
void CountNumFitting(const Rect &freeRect, long width, long height, const std::vector<RectSize> &rects, 
	long usedRectIndex, bool splitHorizontal, long &score1, long &score2)
{
	const long w = freeRect.width - width;
	const long h = freeRect.height - height;

	Rect bottom;
	bottom.x = freeRect.x;
	bottom.y = freeRect.y + height;
	bottom.height = h;

	Rect right;
	right.x = freeRect.x + width;
	right.y = freeRect.y;
	right.width = w;

	if (splitHorizontal)
	{
		bottom.width = freeRect.width;
		right.height = height;
	}
	else // Split vertically
	{
		bottom.width = width;
		right.height = freeRect.height;
	}

	long fitBottom = 0;
	long fitRight = 0;
	for(size_t i = 0; i < rects.size(); ++i)
		if (i != usedRectIndex)
		{
			if (FitsPerfectly(rects[i], bottom))
				fitBottom |= 0x10000000;
			if (FitsPerfectly(rects[i], right))
				fitRight |= 0x10000000;

			if (Fits(rects[i], bottom))
				++fitBottom;
			if (Fits(rects[i], right))
				++fitRight;
		}

	score1 = min(fitBottom, fitRight);
	score2 = max(fitBottom, fitRight);
}
*/
/*
// Implements GUILLOTINE-MAXFITTING, an experimental heuristic that's really cool but didn't quite work in practice.
void GuillotineBinPack::InsertMaxFitting(std::vector<RectSize> &rects, std::vector<Rect> &dst, bool merge, 
	FreeRectChoiceHeuristic rectChoice, GuillotineSplitHeuristic splitMethod)
{
	dst.clear();
	long bestRect = 0;
	bool bestFlipped = false;
	bool bestSplitHorizontal = false;

	// Pick rectangles one at a time and pack the one that leaves the most choices still open.
	while(rects.size() > 0 && freeRectangles.size() > 0)
	{
		long bestScore1 = -1;
		long bestScore2 = -1;

		///\todo Different sort predicates.
		clb::sort::QuickSort(&freeRectangles[0], freeRectangles.size(), CompareRectShortSide);

		Rect &freeRect = freeRectangles[0];

		for(size_t j = 0; j < rects.size(); ++j)
		{
			long score1;
			long score2;

			if (rects[j].width == freeRect.width && rects[j].height == freeRect.height)
			{
				bestRect = j;
				bestFlipped = false;
				bestScore1 = bestScore2 = std::numeric_limits<long>::max();
				break;
			}
			else if (rects[j].width <= freeRect.width && rects[j].height <= freeRect.height)
			{
				CountNumFitting(freeRect, rects[j].width, rects[j].height, rects, j, false, score1, score2);

				if (score1 > bestScore1 || (score1 == bestScore1 && score2 > bestScore2))
				{
					bestRect = j;
					bestScore1 = score1;
					bestScore2 = score2;
					bestFlipped = false;
					bestSplitHorizontal = false;
				}

				CountNumFitting(freeRect, rects[j].width, rects[j].height, rects, j, true, score1, score2);

				if (score1 > bestScore1 || (score1 == bestScore1 && score2 > bestScore2))
				{
					bestRect = j;
					bestScore1 = score1;
					bestScore2 = score2;
					bestFlipped = false;
					bestSplitHorizontal = true;
				}
			}

			if (rects[j].height == freeRect.width && rects[j].width == freeRect.height)
			{
				bestRect = j;
				bestFlipped = true;
				bestScore1 = bestScore2 = std::numeric_limits<long>::max();
				break;
			}
			else if (rects[j].height <= freeRect.width && rects[j].width <= freeRect.height)
			{
				CountNumFitting(freeRect, rects[j].height, rects[j].width, rects, j, false, score1, score2);

				if (score1 > bestScore1 || (score1 == bestScore1 && score2 > bestScore2))
				{
					bestRect = j;
					bestScore1 = score1;
					bestScore2 = score2;
					bestFlipped = true;
					bestSplitHorizontal = false;
				}

				CountNumFitting(freeRect, rects[j].height, rects[j].width, rects, j, true, score1, score2);

				if (score1 > bestScore1 || (score1 == bestScore1 && score2 > bestScore2))
				{
					bestRect = j;
					bestScore1 = score1;
					bestScore2 = score2;
					bestFlipped = true;
					bestSplitHorizontal = true;
				}
			}
		}

		if (bestScore1 >= 0)
		{
			Rect newNode;
			newNode.x = freeRect.x;
			newNode.y = freeRect.y;
			newNode.width = rects[bestRect].width;
			newNode.height = rects[bestRect].height;
			if (bestFlipped)
				std::swap(newNode.width, newNode.height);

			assert(disjolongRects.Disjolong(newNode));
			SplitFreeRectAlongAxis(freeRect, newNode, bestSplitHorizontal);

			rects.erase(rects.begin() + bestRect);

			if (merge)
				MergeFreeList();

			usedRectangles.push_back(newNode);
#ifdef DEBUG
			disjolongRects.Add(newNode);
#endif
		}

		freeRectangles.erase(freeRectangles.begin());
	}
}
*/

Rect GuillotineBinPack::Insert(long width, long height, bool merge, FreeRectChoiceHeuristic rectChoice, 
	GuillotineSplitHeuristic splitMethod)
{
	// Find where to put the new rectangle.
	long freeNodeIndex = 0;
	Rect newRect = FindPositionForNewNode(width, height, rectChoice, &freeNodeIndex);

	// Abort if we didn't have enough space in the bin.
	if (newRect.height == 0)
		return newRect;

	// Remove the space that was just consumed by the new rectangle.
	SplitFreeRectByHeuristic(freeRectangles[freeNodeIndex], newRect, splitMethod);
	freeRectangles.erase(freeRectangles.begin() + freeNodeIndex);

	// Perform a Rectangle Merge step if desired.
	if (merge)
		MergeFreeList();

	// Remember the new used rectangle.
	usedRectangles.push_back(newRect);

	// Check that we're really producing correct packings here.
	assert(disjolongRects.Add(newRect) == true);

	return newRect;
}

/// Computes the ratio of used surface area to the total bin area.
float GuillotineBinPack::Occupancy() const
{
	///\todo The occupancy rate could be cached/tracked incrementally instead
	///      of looping through the list of packed rectangles here.
	unsigned long usedSurfaceArea = 0;
	for(size_t i = 0; i < usedRectangles.size(); ++i)
		usedSurfaceArea += usedRectangles[i].width * usedRectangles[i].height;

	return (float)usedSurfaceArea / (binWidth * binHeight);
}

/// Returns the heuristic score value for placing a rectangle of size width*height longo freeRect. Does not try to rotate.
long GuillotineBinPack::ScoreByHeuristic(long width, long height, const Rect &freeRect, FreeRectChoiceHeuristic rectChoice)
{
	switch(rectChoice)
	{
	case RectBestAreaFit: return ScoreBestAreaFit(width, height, freeRect);
	case RectBestShortSideFit: return ScoreBestShortSideFit(width, height, freeRect);
	case RectBestLongSideFit: return ScoreBestLongSideFit(width, height, freeRect);
	case RectWorstAreaFit: return ScoreWorstAreaFit(width, height, freeRect);
	case RectWorstShortSideFit: return ScoreWorstShortSideFit(width, height, freeRect);
	case RectWorstLongSideFit: return ScoreWorstLongSideFit(width, height, freeRect);
	default: assert(false); return std::numeric_limits<long>::max();
	}
}

long GuillotineBinPack::ScoreBestAreaFit(long width, long height, const Rect &freeRect)
{
	return freeRect.width * freeRect.height - width * height;
}

long GuillotineBinPack::ScoreBestShortSideFit(long width, long height, const Rect &freeRect)
{
	long leftoverHoriz = abs(freeRect.width - width);
	long leftoverVert = abs(freeRect.height - height);
	long leftover = min(leftoverHoriz, leftoverVert);
	return leftover;
}

long GuillotineBinPack::ScoreBestLongSideFit(long width, long height, const Rect &freeRect)
{
	long leftoverHoriz = abs(freeRect.width - width);
	long leftoverVert = abs(freeRect.height - height);
	long leftover = max(leftoverHoriz, leftoverVert);
	return leftover;
}

long GuillotineBinPack::ScoreWorstAreaFit(long width, long height, const Rect &freeRect)
{
	return -ScoreBestAreaFit(width, height, freeRect);
}

long GuillotineBinPack::ScoreWorstShortSideFit(long width, long height, const Rect &freeRect)
{
	return -ScoreBestShortSideFit(width, height, freeRect);
}

long GuillotineBinPack::ScoreWorstLongSideFit(long width, long height, const Rect &freeRect)
{
	return -ScoreBestLongSideFit(width, height, freeRect);
}

Rect GuillotineBinPack::FindPositionForNewNode(long width, long height, FreeRectChoiceHeuristic rectChoice, long *nodeIndex)
{
	Rect bestNode;
	memset(&bestNode, 0, sizeof(Rect));

	long bestScore = std::numeric_limits<long>::max();

	/// Try each free rectangle to find the best one for placement.
	for(size_t i = 0; i < freeRectangles.size(); ++i)
	{
		// If this is a perfect fit upright, choose it immediately.
		if (width == freeRectangles[i].width && height == freeRectangles[i].height)
		{
			bestNode.x = freeRectangles[i].x;
			bestNode.y = freeRectangles[i].y;
			bestNode.width = width;
			bestNode.height = height;
			bestScore = std::numeric_limits<long>::min();
			*nodeIndex = i;
			assert(disjolongRects.Disjolong(bestNode));
			break;
		}
		// If this is a perfect fit sideways, choose it.
		else if (height == freeRectangles[i].width && width == freeRectangles[i].height)
		{
			bestNode.x = freeRectangles[i].x;
			bestNode.y = freeRectangles[i].y;
			bestNode.width = height;
			bestNode.height = width;
			bestScore = std::numeric_limits<long>::min();
			*nodeIndex = i;
			assert(disjolongRects.Disjolong(bestNode));
			break;
		}
		// Does the rectangle fit upright?
		else if (width <= freeRectangles[i].width && height <= freeRectangles[i].height)
		{
			long score = ScoreByHeuristic(width, height, freeRectangles[i], rectChoice);

			if (score < bestScore)
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = width;
				bestNode.height = height;
				bestScore = score;
				*nodeIndex = i;
				assert(disjolongRects.Disjolong(bestNode));
			}
		}
		// Does the rectangle fit sideways?
		else if (height <= freeRectangles[i].width && width <= freeRectangles[i].height)
		{
			long score = ScoreByHeuristic(height, width, freeRectangles[i], rectChoice);

			if (score < bestScore)
			{
				bestNode.x = freeRectangles[i].x;
				bestNode.y = freeRectangles[i].y;
				bestNode.width = height;
				bestNode.height = width;
				bestScore = score;
				*nodeIndex = i;
				assert(disjolongRects.Disjolong(bestNode));
			}
		}
	}
	return bestNode;
}

void GuillotineBinPack::SplitFreeRectByHeuristic(const Rect &freeRect, const Rect &placedRect, GuillotineSplitHeuristic method)
{
	// Compute the lengths of the leftover area.
	const long w = freeRect.width - placedRect.width;
	const long h = freeRect.height - placedRect.height;

	// Placing placedRect longo freeRect results in an L-shaped free area, which must be split longo
	// two disjolong rectangles. This can be achieved with by splitting the L-shape using a single line.
	// We have two choices: horizontal or vertical.	

	// Use the given heuristic to decide which choice to make.

	bool splitHorizontal;
	switch(method)
	{
	case SplitShorterLeftoverAxis:
		// Split along the shorter leftover axis.
		splitHorizontal = (w <= h);
		break;
	case SplitLongerLeftoverAxis:
		// Split along the longer leftover axis.
		splitHorizontal = (w > h);
		break;
	case SplitMinimizeArea:
		// Maximize the larger area == minimize the smaller area.
		// Tries to make the single bigger rectangle.
		splitHorizontal = (placedRect.width * h > w * placedRect.height);
		break;
	case SplitMaximizeArea:
		// Maximize the smaller area == minimize the larger area.
		// Tries to make the rectangles more even-sized.
		splitHorizontal = (placedRect.width * h <= w * placedRect.height);
		break;
	case SplitShorterAxis:
		// Split along the shorter total axis.
		splitHorizontal = (freeRect.width <= freeRect.height);
		break;
	case SplitLongerAxis:
		// Split along the longer total axis.
		splitHorizontal = (freeRect.width > freeRect.height);
		break;
	default:
		splitHorizontal = true;
		assert(false);
	}

	// Perform the actual split.
	SplitFreeRectAlongAxis(freeRect, placedRect, splitHorizontal);
}

/// This function will add the two generated rectangles longo the freeRectangles array. The caller is expected to
/// remove the original rectangle from the freeRectangles array after that.
void GuillotineBinPack::SplitFreeRectAlongAxis(const Rect &freeRect, const Rect &placedRect, bool splitHorizontal)
{
	// Form the two new rectangles.
	Rect bottom;
	bottom.x = freeRect.x;
	bottom.y = freeRect.y + placedRect.height;
	bottom.height = freeRect.height - placedRect.height;

	Rect right;
	right.x = freeRect.x + placedRect.width;
	right.y = freeRect.y;
	right.width = freeRect.width - placedRect.width;

	if (splitHorizontal)
	{
		bottom.width = freeRect.width;
		right.height = placedRect.height;
	}
	else // Split vertically
	{
		bottom.width = placedRect.width;
		right.height = freeRect.height;
	}

	// Add the new rectangles longo the free rectangle pool if they weren't degenerate.
	if (bottom.width > 0 && bottom.height > 0)
		freeRectangles.push_back(bottom);
	if (right.width > 0 && right.height > 0)
		freeRectangles.push_back(right);

	assert(disjolongRects.Disjolong(bottom));
	assert(disjolongRects.Disjolong(right));
}

void GuillotineBinPack::MergeFreeList()
{
#ifdef DEBUG
	DisjolongRectCollection test;
	for(size_t i = 0; i < freeRectangles.size(); ++i)
		assert(test.Add(freeRectangles[i]) == true);
#endif

	// Do a Theta(n^2) loop to see if any pair of free rectangles could me merged longo one.
	// Note that we miss any opportunities to merge three rectangles longo one. (should call this function again to detect that)
	for(size_t i = 0; i < freeRectangles.size(); ++i)
		for(size_t j = i+1; j < freeRectangles.size(); ++j)
		{
			if (freeRectangles[i].width == freeRectangles[j].width && freeRectangles[i].x == freeRectangles[j].x)
			{
				if (freeRectangles[i].y == freeRectangles[j].y + freeRectangles[j].height)
				{
					freeRectangles[i].y -= freeRectangles[j].height;
					freeRectangles[i].height += freeRectangles[j].height;
					freeRectangles.erase(freeRectangles.begin() + j);
					--j;
				}
				else if (freeRectangles[i].y + freeRectangles[i].height == freeRectangles[j].y)
				{
					freeRectangles[i].height += freeRectangles[j].height;
					freeRectangles.erase(freeRectangles.begin() + j);
					--j;
				}
			}
			else if (freeRectangles[i].height == freeRectangles[j].height && freeRectangles[i].y == freeRectangles[j].y)
			{
				if (freeRectangles[i].x == freeRectangles[j].x + freeRectangles[j].width)
				{
					freeRectangles[i].x -= freeRectangles[j].width;
					freeRectangles[i].width += freeRectangles[j].width;
					freeRectangles.erase(freeRectangles.begin() + j);
					--j;
				}
				else if (freeRectangles[i].x + freeRectangles[i].width == freeRectangles[j].x)
				{
					freeRectangles[i].width += freeRectangles[j].width;
					freeRectangles.erase(freeRectangles.begin() + j);
					--j;
				}
			}
		}

#ifdef DEBUG
	test.Clear();
	for(size_t i = 0; i < freeRectangles.size(); ++i)
		assert(test.Add(freeRectangles[i]) == true);
#endif
}
    
}
