class
	PRG

inherit
	ARGUMENTS_32

create
	make

feature {NONE}

	make
		local
			plane: ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]
			cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]
			hyper: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]]
		do
			plane := load_file (argument (1).out)

			create cube.make (1)
			cube.extend (plane)

			create hyper.make (1)
			hyper.extend (cube)

				-- print_cube (next_cube ([cube.count, cube.at (1).count, cube.at (1).at (1).count],
				-- agent sum_around_cube(cube, ?, ?, ?),
				-- agent cell_value_cube(cube, ?, ?, ?)
				-- ))

			cube := iterate_cube (cube, 6)
			print (sum_cube (cube).out + "%N")

			hyper := iterate_hyper (hyper, 6)
			print (sum_hyper (hyper).out + "%N")
		end

	iterate_hyper (hyper: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]] n: INTEGER): ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]]
		do
			Result := hyper
			across
				1 |..| n as i
			loop
				Result := next_hyper ([Result.count, Result.at (1).count, Result.at (1).at (1).count, Result.at (1).at (1).at (1).count],
					agent sum_around_hyper(Result, ?, ?, ?, ?),
					agent cell_value_hyper(Result, ?, ?, ?, ?)
					)
			end
		end

	iterate_cube (cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]] n: INTEGER): ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]
		do
			Result := cube
			across
				1 |..| n as i
			loop
				Result := next_cube ([Result.count, Result.at (1).count, Result.at (1).at (1).count],
					agent sum_around_cube(Result, ?, ?, ?),
					agent cell_value_cube(Result, ?, ?, ?)
					)
			end
		end

	next_hyper (size: TUPLE [INTEGER, INTEGER, INTEGER, INTEGER]
		sum_around: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER, INTEGER], INTEGER]
		cell_value: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER, INTEGER], BOOLEAN]
		): ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]]
		local
		do
			create Result.make ({INTEGER} / size.at (1) + 2)

			across
				1 |..| Result.capacity as w
			loop
				Result.extend (next_cube ([{INTEGER} / size.at (2), {INTEGER} / size.at (3), {INTEGER} / size.at (4)],
				agent  (sa: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER, INTEGER], INTEGER] ww: INTEGER xx: INTEGER yy: INTEGER zz: INTEGER): INTEGER do Result := sa.item ([ww, xx, yy, zz]) end (sum_around, w.item, ?, ?, ?),
				agent  (cv: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER, INTEGER], BOOLEAN] ww: INTEGER xx: INTEGER yy: INTEGER zz: INTEGER): BOOLEAN do Result := cv.item ([ww, xx, yy, zz]) end (cell_value, w.item - 1, ?, ?, ?)
				))
			end
		end

	next_cube (size: TUPLE [INTEGER, INTEGER, INTEGER]
		sum_around: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER], INTEGER]
		cell_value: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER], BOOLEAN]
		): ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]
		local
		do
			create Result.make ({INTEGER} / size.at (1) + 2)

			across
				1 |..| Result.capacity as x
			loop
				Result.extend (next_plane ([{INTEGER} / size.at (2), {INTEGER} / size.at (3)],
				agent  (sa: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER], INTEGER] xx: INTEGER yy: INTEGER zz: INTEGER): INTEGER do Result := sa.item ([xx, yy, zz]) end (sum_around, x.item, ?, ?),
				agent  (cv: FUNCTION [TUPLE [INTEGER, INTEGER, INTEGER], BOOLEAN] xx: INTEGER yy: INTEGER zz: INTEGER): BOOLEAN do Result := cv.item ([xx, yy, zz]) end (cell_value, x.item - 1, ?, ?)
				))
			end
		end

	next_plane (size: TUPLE [INTEGER, INTEGER]
		sum_around: FUNCTION [TUPLE [INTEGER, INTEGER], INTEGER]
		cell_value: FUNCTION [TUPLE [INTEGER, INTEGER], BOOLEAN]
		): ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]
		local
		do
			create Result.make ({INTEGER} / size.at (1) + 2)

			across
				1 |..| Result.capacity as y
			loop
				Result.extend (next_line ([{INTEGER} / size.at (2)],
				agent  (sa: FUNCTION [TUPLE [INTEGER, INTEGER], INTEGER] yy: INTEGER zz: INTEGER): INTEGER do Result := sa.item ([yy, zz]) end (sum_around, y.item, ?),
				agent  (cv: FUNCTION [TUPLE [INTEGER, INTEGER], BOOLEAN] yy: INTEGER zz: INTEGER): BOOLEAN do Result := cv.item ([yy, zz]) end (cell_value, y.item - 1, ?)
				))
			end
		end

	next_line (size: TUPLE [INTEGER]
		sum_around: FUNCTION [TUPLE [INTEGER], INTEGER]
		cell_value: FUNCTION [TUPLE [INTEGER], BOOLEAN]
		): ARRAYED_LIST [BOOLEAN]
		local
		do
			create Result.make ({INTEGER} / size.at (1) + 2)

			across
				1 |..| Result.capacity as z
			loop
				Result.extend (next_cell (agent  (sa: FUNCTION [TUPLE [INTEGER], INTEGER] zz: INTEGER): INTEGER do Result := sa.item ([zz]) end (sum_around, z.item),
				agent  (cv: FUNCTION [TUPLE [INTEGER], BOOLEAN] zz: INTEGER): BOOLEAN do Result := cv.item ([zz]) end (cell_value, z.item - 1)
				))
			end
		end

	next_cell (
		sum_around: FUNCTION [TUPLE, INTEGER]
		cell_value: FUNCTION [TUPLE, BOOLEAN]
		): BOOLEAN
		local
			cell: BOOLEAN
			sum: INTEGER
		do
			cell := cell_value.item ([])
			sum := sum_around.item ([])

			Result := cell and sum >= 3 and sum <= 4 or not cell and sum = 3
		end

	sum_around_hyper (hyper: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]] w: INTEGER x: INTEGER y: INTEGER z: INTEGER): INTEGER
		local
			cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]
		do
			across
				(w - 2) |..| w as ww
			loop
				if hyper.valid_index (ww.item) then
					cube := hyper.at (ww.item)
					Result := Result + sum_around_cube (cube, x, y, z)
				end
			end
		end

	sum_around_cube (cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]] x: INTEGER y: INTEGER z: INTEGER): INTEGER
		local
			plane: ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]
		do
			across
				(x - 2) |..| x as xx
			loop
				if cube.valid_index (xx.item) then
					plane := cube.at (xx.item)
					Result := Result + sum_around_plane (plane, y, z)
				end
			end
		end

	sum_around_plane (plane: ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]] y: INTEGER z: INTEGER): INTEGER
		local
			line: ARRAYED_LIST [BOOLEAN]
		do
			across
				(y - 2) |..| y as yy
			loop
				if plane.valid_index (yy.item) then
					line := plane.at (yy.item)
					Result := Result + sum_around_line (line, z)
				end
			end
		end

	sum_around_line (line: ARRAYED_LIST [BOOLEAN] z: INTEGER): INTEGER
		local
			cell: BOOLEAN
		do
			across
				(z - 2) |..| z as zz
			loop
				if line.valid_index (zz.item) then
					cell := line.at (zz.item)

					if cell then
						Result := Result + 1
					end
				end
			end
		end

	cell_value_hyper (hyper: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]] w: INTEGER x: INTEGER y: INTEGER z: INTEGER): BOOLEAN
		do
			if hyper.valid_index (w) then
				Result := cell_value_cube (hyper.at (w), x, y, z)
			end
		end

	cell_value_cube (cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]] x: INTEGER y: INTEGER z: INTEGER): BOOLEAN
		do
			if cube.valid_index (x) then
				Result := cell_value_plane (cube.at (x), y, z)
			end
		end

	cell_value_plane (plane: ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]] y: INTEGER z: INTEGER): BOOLEAN
		do
			if plane.valid_index (y) then
				Result := cell_value_line (plane.at (y), z)
			end
		end

	cell_value_line (line: ARRAYED_LIST [BOOLEAN] z: INTEGER): BOOLEAN
		do
			if line.valid_index (z) then
				Result := line.at (z)
			end
		end

	print_hyper (hyper: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]])
		do
			across hyper as cube loop
				print_cube (cube.item)
			end
		end

	print_cube (cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]])
		do
			across cube as plane loop
				print_plane (plane.item)
			end
		end

	print_plane (plane: ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]])
		do
			across plane as line loop
				print_line (line.item)
			end
			print ("%N")
		end

	print_line (line: ARRAYED_LIST [BOOLEAN])
		do
			across line as cell loop
				if cell.item then
					print ("#")
				else
					print (".")
				end
			end
			print ("%N")
		end

	sum_hyper (hyper: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]]): INTEGER
		do
			across hyper as cube loop
				Result := Result + sum_cube (cube.item)
			end
		end

	sum_cube (cube: ARRAYED_LIST [ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]]): INTEGER
		do
			across cube as plane loop
				Result := Result + sum_plane (plane.item)
			end
		end

	sum_plane (plane: ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]): INTEGER
		do
			across plane as line loop
				Result := Result + sum_line (line.item)
			end
		end

	sum_line (line: ARRAYED_LIST [BOOLEAN]): INTEGER
		do
			across line as cell loop
				if cell.item then
					Result := Result + 1
				end
			end
		end

	load_file (name: STRING): ARRAYED_LIST [ARRAYED_LIST [BOOLEAN]]
		local
			file: PLAIN_TEXT_FILE
			line: ARRAYED_LIST [BOOLEAN]
		do
			create file.make_open_read (name)

			create Result.make (10)

			create line.make (10)

			from
				file.read_character
			until
				file.exhausted
			loop
				if file.last_character = '#' then
					line.extend (true)
				elseif file.last_character = '.' then
					line.extend (false)
				else
					Result.extend (line)
					create line.make (10)
				end
				file.read_character
			end

			file.close
		end

end
