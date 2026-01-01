import { MedusaRequest, MedusaResponse } from '@medusajs/framework'
import { ContainerRegistrationKeys } from '@medusajs/framework/utils'

/**
 * @oas [get] /store/products
 * operationId: "StoreListProducts"
 * summary: "List Products"
 * description: "Retrieves a list of products."
 * parameters:
 *   - name: offset
 *     in: query
 *     schema:
 *       type: number
 *     required: false
 *     description: The number of items to skip before starting to collect the result set.
 *   - name: limit
 *     in: query
 *     schema:
 *       type: number
 *     required: false
 *     description: The number of items to return.
 *   - name: fields
 *     in: query
 *     schema:
 *       type: string
 *     required: false
 *     description: Comma-separated fields to include in the response.
 *   - name: order
 *     in: query
 *     schema:
 *       type: string
 *     required: false
 *     description: The order of the returned items.
 * responses:
 *   "200":
 *     description: OK
 *     content:
 *       application/json:
 *         schema:
 *           type: object
 *           properties:
 *             products:
 *               type: array
 *               items:
 *                 $ref: "#/components/schemas/Product"
 *             count:
 *               type: integer
 *               description: The total number of items available
 *             offset:
 *               type: integer
 *               description: The number of items skipped before these items
 *             limit:
 *               type: integer
 *               description: The number of items per page
 * tags:
 *   - Store Products
 */
export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Sanitize fields parameter to remove invalid calculated_price references
  let fields: string[] = []
  if (req.query.fields) {
    const fieldsString = Array.isArray(req.query.fields)
      ? req.query.fields[0]
      : req.query.fields
    fields = fieldsString
      .split(',')
      .map((f) => f.trim())
      .filter((f) => {
        // Remove invalid calculated_price field references
        // Keep *variants but remove *variants.calculated_price or variants.calculated_price
        if (
          f.includes('calculated_price') &&
          (f.includes('variants.calculated_price') ||
            f.includes('*variants.calculated_price'))
        ) {
          return false
        }
        return true
      })
  }

  // Parse pagination
  const offset = req.query.offset
    ? parseInt(Array.isArray(req.query.offset) ? req.query.offset[0] : req.query.offset)
    : 0
  const limit = req.query.limit
    ? parseInt(Array.isArray(req.query.limit) ? req.query.limit[0] : req.query.limit)
    : 100

  // Build filters - only include status if not provided (default to published for store)
  const filters: Record<string, any> = {
    status: 'published'
  }

  // Use default fields if none provided or after sanitization
  if (fields.length === 0) {
    fields = [
      'id',
      'title',
      'handle',
      'thumbnail',
      '*variants',
      '*variants.prices'
    ]
  }

  const { data: products, metadata } = await query.graph({
    entity: 'product',
    fields: fields,
    filters: filters,
    pagination: {
      skip: offset,
      take: limit
    }
  })

  res.json({
    products,
    count: metadata?.count ?? 0,
    offset: metadata?.skip ?? offset,
    limit: metadata?.take ?? limit
  })
}

