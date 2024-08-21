using Images, Plots, Graphs, Colors, ImageFiltering, LinearAlgebra, ImageProjectiveGeometry


function processImage(img, retain, segments, sigma, epsilon)

	# Step 2: Convert to grayscale
	gray_img = Gray.(img)

	# Step 3: Apply Gaussian filter
	filtered_img = imfilter(gray_img, Kernel.gaussian(sigma))

	# Initialize the graph
	img_height, img_width = size(filtered_img)
	num_pixels = img_height * img_width
	g = Graph(num_pixels) # Creates a graph with num_pixels nodes

	# Define neighbor offsets for 8-connectivity
	neighbor_offsets = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]

	# Add edges based on the 10 percent rule
	for row in 1:img_height
		for col in 1:img_width
			current_pixel_value = filtered_img[row, col]
			current_node_index = (row - 1) * img_width + col
			for (delta_row, delta_col) in neighbor_offsets
				neighbor_row = row + delta_row
				neighbor_col = col + delta_col
				if 1 <= neighbor_row <= img_height && 1 <= neighbor_col <= img_width
					neighbor_value = filtered_img[neighbor_row, neighbor_col]
					neighbor_node_index = (neighbor_row - 1) * img_width + neighbor_col
					if within(current_pixel_value, neighbor_value,epsilon)
						add_edge!(g, current_node_index, neighbor_node_index)
					end
				end
			end
		end
	end

	# Find connected components
	components = connected_components(g)

	# Calculate the size of each component
	component_sizes = [(comp, length(comp)) for comp in components]

	# Sort components by size in descending order and select the top 8
	sorted_components = sort(component_sizes, by = x -> x[2], rev = true)
	components_top = first.(sorted_components[1:min(segments, end)])
	num_components = length(components_top)

	# Create an empty image with the same dimensions as the original, but colored
	colored_img = zeros(RGB, img_height, img_width)

	# Generate a unique color for each component
	colors = distinguishable_colors(num_components)

	# Map each node to its component
	node_to_component = zeros(Int, num_pixels)
	for (component_index, component) in enumerate(components_top)
		for node in component
			node_to_component[node] = component_index
		end
	end

	# Adjust component_index when accessing the colors array
	for row in 1:img_height
		for col in 1:img_width
			node_index = (row - 1) * img_width + col
			component_index = node_to_component[node_index]
			safe_component_index = max(component_index, 1)
			colored_img[row, col] = colors[safe_component_index]
		end
	end

	display(colored_img)

	# Calculate the center of the image
	center_y, center_x = img_height / 2, img_width / 2

	# Calculate and draw circles for each component's centroid
	distance_scores= []
	for component in components_top
		y_sum, x_sum, count = 0, 0, 0
		distance_score = 0  # Initialize distance score for the current component
		for pixel_index in component
			row = div(pixel_index - 1, img_width) + 1
			col = rem(pixel_index - 1, img_width) + 1
			# Calculate distance from the center and add to the distance score
			dist = sqrt((row - center_y)^2 + (col - center_x)^2)
			distance_score += dist
		end
		distance_score /= length(component)
		push!(distance_scores, distance_score)
	end

	# display(colored_img)

	component_distance_pairs = zip(components_top, distance_scores)

	# Convert the zipped iterator to an array
	component_distance_array = collect(component_distance_pairs)

	# Sort the array of tuples by the distance score
	sorted_components_by_distance = sort(component_distance_array, by = x -> x[2])

	# Select the components with the three lowest distance scores
	lowest_distance_components = first.(sorted_components_by_distance[1:retain])

	# Create a new image for displaying the selected components
	selected_components_img = zeros(RGB, img_height, img_width)

	# Color only the selected components
	for component in lowest_distance_components
		for node in component
			row = div(node - 1, img_width) + 1
			col = rem(node - 1, img_width) + 1
			# Find the component index to get the correct color
			component_index = findfirst(x -> x == component, components_top)
			selected_components_img[row, col] = colors[component_index]
		 end
	end


	return selected_components_img
end

# Helper function to check if two values are within 10 percent of each other
function within(val1, val2,epsilon)
	return abs(val1 - val2) <= epsilon * max(val1, val2)
end

# Define a criterion for colored pixels (example: not close to white)
function isColored(pixel)
	return norm(pixel - RGB(1,1,1)) > 0.1
end

function transformImage(selected_components_img, pixels::Int)
	# Function to calculate distance between two points
	distance(p1, p2) = norm(p1 - p2)

	# Identify the center of the image
	center = (size(selected_components_img, 1) / 2, size(selected_components_img, 2) / 2)

	# Divide the image into quadrants and find the farthest colored pixel in each
	farthest_pixels = Dict()
	for quadrant in 1:4
		farthest_pixels[quadrant] = (0, 0) # Initialize with a dummy value
	end
	max_distances = fill(0.0, 4)

	# Define a criterion for colored pixels (example: not close to white)
	function isColored(pixel)
		return norm(pixel - RGB(1,1,1)) > 0.1
	end

	# Scan the image for colored pixels and store their indices
	colored_indices = []
	for row in 1:size(selected_components_img, 1)
		for col in 1:size(selected_components_img, 2)
			if isColored(selected_components_img[row, col])
				push!(colored_indices, (row, col))
			end
		end
	end

	# Assuming colored_indices is defined; need to define or pass as parameter
	for index in colored_indices
		# Convert CartesianIndex to a tuple
		(row, col) = Tuple(index)
		
		# Determine the quadrant for the current pixel
		quadrant = (row > center[1]) * 2 + (col > center[2]) + 1
		
		# Calculate distance from the center
		current_distance = norm([row, col] - [center[1], center[2]])
		
		# Update the farthest pixel if the current pixel is farther
		if current_distance > max_distances[quadrant]
			max_distances[quadrant] = current_distance
			farthest_pixels[quadrant] = (row, col)
		end
	end

	source_points = [farthest_pixels[1][2] farthest_pixels[3][2] farthest_pixels[4][2] farthest_pixels[2][2];
					 farthest_pixels[1][1] farthest_pixels[3][1] farthest_pixels[4][1] farthest_pixels[2][1]]

	# Define the destination square's corners
	dest_points = [0 0 pixels pixels; 0 pixels pixels 0]  # Assuming top-left, bottom-left, top-right, bottom-right

	# Convert to homogeneous coordinates by appending a row of ones
	src_points_homogeneous = [source_points; ones(1, size(source_points, 2))]
	dest_points_homogeneous = [dest_points; ones(1, size(dest_points, 2))]

	# Compute the homography matrix
	H = homography2d(src_points_homogeneous, dest_points_homogeneous)

	# Get the dimensions of the image
	height2, width2 = size(selected_components_img)

	# Create an empty image to store the transformed result
	transformed_img = fill(RGB{N0f8}(0,0,0), height2, width2)

	# Function to apply homography to a point
	function apply_homography(H, x, y)
		pt = H * [x, y, 1]
		return pt[1]/pt[3], pt[2]/pt[3]
	end

	# Apply the homography transformation
	for i in 1:height2
		for j in 1:width2
			x_new, y_new = apply_homography(H, j, i)
			x_new = round(Int, x_new)
			y_new = round(Int, y_new)
			if x_new > 0 && x_new <= width2 && y_new > 0 && y_new <= height2
				transformed_img[y_new, x_new] = selected_components_img[i, j]
			end
		end
	end

    return transformed_img[1:pixels, 1:pixels]
end


function add_edges_for_neighbors(graph, img, row, col, colored_indices_set)
	neighbors = [
		(row-1, col-1), (row-1, col), (row-1, col+1),
		(row, col-1),                 (row, col+1),
		(row+1, col-1), (row+1, col), (row+1, col+1)
	]
	for (nrow, ncol) in neighbors
		if nrow >= 1 && nrow <= size(img, 1) && ncol >= 1 && ncol <= size(img, 2) && !((nrow, ncol) in colored_indices_set)
			add_edge!(graph, Edge((row-1)*size(img, 2) + col, (nrow-1)*size(img, 2) + ncol))
		end
	end
end

function get_data(img)
	graph = Graph(size(img, 1) * size(img, 2))  # Create a graph with one vertex for each pixel
	# Scan the image for colored pixels and store their indices
	colored_indices = []
	for row in 1:size(img, 1)
		for col in 1:size(img, 2)
			if isColored(img[row, col])
				push!(colored_indices, (row, col))
			end
		end
	end
	colored_indices_set = Set(colored_indices)  # Convert list to set for efficient lookup

	for row in 1:size(img, 1)
		for col in 1:size(img, 2)
			if !((row, col) in colored_indices_set)  # Check if the pixel is not colored
				add_edges_for_neighbors(graph, img, row, col, colored_indices_set)
			end
		end
	end

	components = connected_components(graph)
	# Sort components by size in descending order and take the first two
	largest_two_components = sort(components, by=length, rev=true)[1:1]

	# Initialize the mask with zeros, assuming binary_img is a 2D array
	mask = zeros(size(img))

	img_height, img_width = size(img)
	# Update the mask for the selected components
	for component in largest_two_components
		for node in component
			# Assuming `node` represents a linear index in the binary image
			row = div(node - 1, img_width) + 1
			col = rem(node - 1, img_width) + 1
			mask[row, col] = 1  # Set the pixel to white
		end
	end

	data = Gray.(mask)
	
	return data
end

function calculate_center_of_mass(signal)
	positions = 1:length(signal)  # Adjusted to work with a vector input
	numerator = sum(signal .* positions)
	denominator = sum(signal)
	return denominator == 0 ? 0 : numerator / denominator
end

function get_signal(data)
	# Initialize a matrix filled with zeros
	com_signal = zeros(size(data, 2))
	for col in 1:size(data, 2)  # Iterate over columns
		# Calculate the center of mass for the current column
		com = calculate_center_of_mass(data[:, col])
		
		# Round the COM to the nearest integer to use as an index
		com_index = round(Int, com)
		
		# Ensure com_index is within the valid range of row indices
		com_index = max(1, min(com_index, size(data, 1)))
		
		com_signal[col] = com_index
	end
	
	return  com_signal
end